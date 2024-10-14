module gittools

import freeflowuniverse.crystallib.core.base
import json
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import time
import os
import freeflowuniverse.crystallib.osal.sshagent


// Return rich path object from our library crystal lib
pub fn (repo GitRepo) patho() !pathlib.Path {
	repo.check()!
	return pathlib.get_dir(path: repo.get_path()!, create: false)!
}

// Save repo to redis cache
fn (repo GitRepo) redis_save() ! {
	mut context := base.context()!
	mut redis := context.redis()!
	repo_json := json.encode(repo)
	cache_key := repo.get_cache_key()
	redis.set(cache_key, repo_json)!
}

// Get repo from redis cache
fn (mut repo GitRepo) redis_load() ! {
	mut context := base.context()!
	mut redis := context.redis()!
	cache_key := repo.get_cache_key()
	repo_json := redis.get(cache_key)!
	if repo_json.len > 0 {
		repo = json.decode(GitRepo, repo_json)!
	}
}

pub fn (mut repo GitRepo) status_update(args StatusUpdateArgs) ! {
	// Check current time vs last check, if needed (check period) then load
	repo.redis_load()! // Ensure we have the situation from redis
	current_time := int(time.now().unix())
	if args.reload || repo.config.remote_check_period == 0
		|| current_time - repo.status_remote.last_check >= repo.config.remote_check_period {
		repo.load()!
	}
}

// Load repo information
fn (mut repo GitRepo) load() ! {
	console.print_debug('load ${repo.get_key()}')
	path := repo.get_path()!

	// Fetch local branch or see if detached
	cmd_result := osal.execute_silent('git -C ${path} rev-parse --abbrev-ref HEAD') or {
		return error('Failed to fetch branch info: ${err}')
	}

	if cmd_result.trim_space() == 'HEAD' {
		repo.status_local.detached = true
		// If detached, get the tag and fill it in GitRepoStatusLocal property
		tag_result := osal.execute_silent('git -C ${path} describe --tags --exact-match') or { '' }
		repo.status_local.tag = tag_result.trim_space()
	} else {
		// If not detached, fill in branch
		repo.status_local.detached = false
		repo.status_local.branch = cmd_result.trim_space()
	}

	// Fetch local ref (commit hash)
	ref_result := osal.execute_silent('git -C ${path} rev-parse HEAD') or {
		return error('Failed to fetch commit hash: ${err}')
	}
	repo.status_local.ref = ref_result.trim_space()

	// Set the latest local commit
	repo.status_local.latest_commit = ref_result.trim_space()

	// Fetch all remote branches and refs (hashes) and fill into GitRepoStatusRemote
	branches_result := osal.execute_silent('git -C ${path} branch -r --format "%(refname:lstrip=2) %(objectname)"') or {
		return error('Failed to fetch remote branches: ${err}')
	}

	for line in branches_result.split('\n') {
		if line.trim_space() != '' {
			parts := line.split(' ')
			if parts.len == 2 {
				mut branch_name := string(parts[0].trim_space())
				if branch_name.contains('origin/'){
					branch_name = branch_name.replace('origin/', '')
				}

				commit_hash := parts[1].trim_space()
				repo.status_remote.branches[branch_name] = commit_hash

				// Set the latest remote commit for the current branch
				if branch_name == repo.status_local.branch {
					repo.status_remote.latest_commit = commit_hash
				}
			}
		}
	}

	// Fetch all remote tags and refs (hashes) and fill into GitRepoStatusRemote
	tags_result := osal.execute_silent('git -C ${path} show-ref --tags') or { '' }

	for line in tags_result.split('\n') {
		if line.trim_space() != '' {
			parts := line.split(' ')
			if parts.len == 2 {
				commit_hash := parts[0].trim_space()
				tag_name := parts[1].all_after('refs/tags/').trim_space()
				repo.status_remote.tags[tag_name] = commit_hash
			}
		}
	}

	// Fill in all dates of checks (remote & local)
	repo.status_local.last_check = int(time.now().unix())
	repo.status_remote.last_check = int(time.now().unix())
}


// Check if repo path exists and validate fields
pub fn (repo GitRepo) check() ! {
	path_string := repo.get_path()!
	if repo.gs.coderoot.path == '' {
		return error('Coderoot cannot be empty')
	}
	if repo.provider == '' {
		return error('Provider cannot be empty')
	}
	if repo.account == '' {
		return error('Account cannot be empty')
	}
	if repo.name == '' {
		return error('Name cannot be empty')
	}

	if !os.exists(path_string) {
		return error('Path does not exist: ${path_string}')
	}
}

// Create GitLocation from the path within the Git repository
pub fn (mut gs GitRepo) gitlocation_from_path(path string) !GitLocation {
	if path.starts_with('/') || path.starts_with('~') {
		return error('Path must be relative, cannot start with / or ~')
	}

	mut git_path := gs.patho()!
	if !os.exists(git_path.path) {
		return error('Path does not exist inside the repository: ${git_path.path}')
	}

	return GitLocation{
		provider: gs.provider
		account:  gs.account
		name:     gs.name
		branch:   gs.status_local.branch
		tag:      gs.status_local.tag
		path:     path
	}
}

fn (self GitRepo) path_account() !pathlib.Path {
	self.check()!

	mut path_string := '${self.gs.coderoot.path}/${self.provider}/${self.account}'
	return pathlib.get_dir(path: path_string, create: true) or { panic("couldn't get directory") }
}

// url_get returns the URL of a git address
fn (self GitRepo) url_get() !string {
	if sshagent.loaded() {
		return self.url_ssh_get()!
	} else {
		return self.url_http_get()!
	}
}

fn (self GitRepo) url_ssh_get() !string {
	self.check()!
	mut provider := self.provider
	if provider == 'github' {
		provider = 'github.com'
	}
	return 'git@${provider}:${self.account}/${self.name}.git'
}

fn (self GitRepo) url_http_get() !string {
	self.check()!
	mut provider := self.provider
	if provider == 'github' {
		provider = 'github.com'
	}
	return 'https://${provider}/${self.account}/${self.name}'
}

// Return HTTP URL with branch inside
fn (self GitRepo) url_http_with_branch_get() !string {
	self.check()!
	u := self.url_http_get()!
	// TODO: prob not ok because this is branch of what can be found on the filesystem
	if self.status_local.branch != '' {
		return '${u}/tree/${self.status_local.branch}'
	} else {
		return u
	}
}
