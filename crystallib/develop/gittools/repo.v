module gittools

import freeflowuniverse.crystallib.core.base
import json
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import time
import os
import freeflowuniverse.crystallib.osal.sshagent

fn ( repo GitRepo) key() string {
	return '${repo.gs.key}:${repo.provider}:${repo.account}:${repo.name}'
}

fn ( repo GitRepo) cache_key() string {
	return 'git:repos:${repo.gs.key}:${repo.provider}:${repo.account}:${repo.name}'
}

// remove cache
fn (repo GitRepo) cache_delete() ! {
	mut c := base.context()!
	mut redis := c.redis()!	
	redis.del(repo.cache_key())!
}


pub fn (repo GitRepo) path() !string {
	return '${repo.gs.coderoot.path}/${repo.provider}/${repo.account}/${repo.name}'
}

//return rich path object (from our library crystal lib)
pub fn (repo GitRepo) patho() !pathlib.Path {
	repo.check()!
	return pathlib.get_dir(path:repo.path()!,create:false)!
}

// save repo to redis cache
fn (repo GitRepo) redis_save() ! {
	mut c := base.context()!
	mut redis := c.redis()!
	repo_json := json.encode(repo)
	redis.set(repo.cache_key(), repo_json)!
}

// get repo from redis cache
fn (mut repo GitRepo) redis_load() ! {
	mut c := base.context()!
	mut redis := c.redis()!
	repo_json := redis.get(repo.cache_key())!
	if repo_json.len>0{
		repo = json.decode(GitRepo, repo_json)!
	}	
}


@[params]
pub struct StatusUpdateArgs{
	reload bool
}

pub fn (mut repo GitRepo) status_update(args StatusUpdateArgs) ! {
	// Check current time vs last check, if needed (check period) then load
	repo.redis_load()! //make sure we have situation from redis
	current_time := int(time.now().unix())
	if args.reload || repo.config.remote_check_period == 0 || current_time - repo.status_remote.last_check >= repo.config.remote_check_period {
		repo.load()!
	}
}

// load repo information
fn (mut repo GitRepo) load() ! {
	// Fetch local branch or see if detached
	console.print_debug("load ${repo.key()}")
	path:=repo.path()!
	cmd_result := osal.execute_silent('git -C ${path} rev-parse --abbrev-ref HEAD') or {
		return error('Failed to fetch branch info: $err')
	}

	if cmd_result.trim_space() == 'HEAD' {
		repo.status_local.detached = true
		// If detached, get the tag and fill it in GitRepoStatusLocal property
		tag_result := osal.execute_silent('git -C ${path} describe --tags --exact-match') or {
			''
		}
		repo.status_local.tag = tag_result.trim_space()
	} else {
		// If not detached, fill in branch
		repo.status_local.detached = false
		repo.status_local.branch = cmd_result.trim_space()
	}

	// Fetch local ref (commit hash)
	ref_result := osal.execute_silent('git -C ${path} rev-parse HEAD') or {
		return error('Failed to fetch commit hash: $err')
	}
	repo.status_local.ref = ref_result.trim_space()

	// Fetch all remote branches and refs (hashes) and fill into GitRepoStatusRemote
	branches_result := osal.execute_silent('git -C ${path} branch -r --format "%(refname:lstrip=2) %(objectname)"') or {
		return error('Failed to fetch remote branches: $err')
	}

	for line in branches_result.split('\n') {
		if line.trim_space() != '' {
			parts := line.split(' ')
			if parts.len == 2 {
				branch_name := parts[0].trim_space()
				commit_hash := parts[1].trim_space()
				repo.status_remote.branches[branch_name] = commit_hash
			}
		}
	}

	// Fetch all remote tags and refs (hashes) and fill into GitRepoStatusRemote
	tags_result := osal.execute_silent('git -C ${path} show-ref --tags') or {
		''
	}

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
	//println(repo)
}

// check if repo path exists and validate fields
pub fn (repo GitRepo) check() ! {
	path_string:=repo.path()!
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
		return error('Path does not exist: $path_string')
	}
}

// relative path inside the gitstructure, pointing to the repo
pub fn (repo GitRepo) path_relative() !string {
	mut mypath:=repo.patho()!
	return mypath.path_relative(repo.gs.coderoot.path) or { panic('couldnt get relative path') }
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

	mut git_location := GitLocation{
		provider: gs.provider
		account: gs.account
		name: gs.name
		branch: gs.status_local.branch
		tag: gs.status_local.tag
		path: path
	}

	return git_location
}



// GitRepo status getters
pub fn (repo GitRepo) need_pull() bool {
	// Determine if the repo needs to pull based on status_remote and status_local information
	return repo.status_remote.latest_commit != repo.status_local.ref
}

pub fn (repo GitRepo) need_push() bool {
	// Determine if the repo needs to push based on status_remote and status_local information
	return repo.status_local.ref != '' && repo.status_remote.latest_commit == ''
}

pub fn (repo GitRepo) need_commit() bool {
	// Determine if the repo needs a commit based on local status information
	return repo.status_local.ref == ''
}


fn (self GitRepo) path_account() !pathlib.Path {
	self.check()!

	mut path_string := '${self.gs.coderoot.path}/${self.provider}/${self.account}'
	path := pathlib.get_dir(
		path: path_string
		create: true
	) or { panic('couldnt get directory') }
	return path
}

// url_get returns the url of a git address
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

// return http url with branch inside
fn (self GitRepo) url_http_with_branch_get() !string {
	self.check()!
	u := self.url_http_get()!
	//TODO: prob not ok because this is branch of what can be found on filesystem
	if self.status_local.branch != '' {
		return '${u}/tree/${self.status_local.branch}'
	} else {
		return u
	}
}
