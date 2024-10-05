module gittools2

import freeflowuniverse.crystallib.core.base
import json

fn ( repo GitRepo) cache_key() string {
	return 'git:${repo.key}:${repo.provider}:${repo.account}:${repo.name}'
}

// remove cache
fn (repo GitRepo) cache_delete() ! {
	mut c := base.context()!
	mut redis := c.redis()!	
	redis.del(repo.cache_key())!
}


pub fn (repo GitRepo) path() !pathlib.Path {
	return '${repo.coderoot}/${repo.provider}/${repo.account}/${repo.name}'
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
	if repo_json{
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
	current_time := int(time.now().unix)
	if args.reload || repo.config.remote_check_period == 0 || current_time - repo.status_remote.last_check >= repo.config.remote_check_period {
		repo.load()!
	}
}

// load repo information
fn (mut repo GitRepo) load() ! {
	// Fetch local branch or see if detached
	path:="${repo.coderoot}/${repo.provider}/${repo.account}/${repo.name}"
	cmd_result := cmdtools.run('git -C ${path} rev-parse --abbrev-ref HEAD') or {
		return error('Failed to fetch branch info: $err')
	}

	if cmd_result.trim() == 'HEAD' {
		repo.status_local.detached = true
		// If detached, get the tag and fill it in GitRepoStatusLocal property
		tag_result := cmdtools.run('git -C ${path} describe --tags --exact-match') or {
			''
		}
		repo.status_local.tag = tag_result.trim()
	} else {
		// If not detached, fill in branch
		repo.status_local.detached = false
		repo.status_local.branch = cmd_result.trim()
	}

	// Fetch local ref (commit hash)
	ref_result := cmdtools.run('git -C ${path} rev-parse HEAD') or {
		return error('Failed to fetch commit hash: $err')
	}
	repo.status_local.ref = ref_result.trim()

	// Fetch all remote branches and refs (hashes) and fill into GitRepoStatusRemote
	branches_result := cmdtools.run('git -C ${path} branch -r --format "%(refname:lstrip=2) %(objectname)"') or {
		return error('Failed to fetch remote branches: $err')
	}

	for line in branches_result.split('\n') {
		if line.trim() != '' {
			parts := line.split(' ')
			if parts.len == 2 {
				branch_name := parts[0].trim()
				commit_hash := parts[1].trim()
				repo.status_remote.branches[branch_name] = commit_hash
			}
		}
	}

	// Fetch all remote tags and refs (hashes) and fill into GitRepoStatusRemote
	tags_result := cmdtools.run('git -C ${path} show-ref --tags') or {
		return error('Failed to fetch remote tags: $err')
	}

	for line in tags_result.split('\n') {
		if line.trim() != '' {
			parts := line.split(' ')
			if parts.len == 2 {
				commit_hash := parts[0].trim()
				tag_name := parts[1].all_after('refs/tags/').trim()
				repo.status_remote.tags[tag_name] = commit_hash
			}
		}
	}

	// Fill in all dates of checks (remote & local)
	repo.status_local.last_check = int(time.now().unix)
	repo.status_remote.last_check = int(time.now().unix)
}

// check if repo path exists and validate fields
pub fn (repo GitRepo) check() ! {
	path_string:=repo.path()!
	if repo.coderoot == '' {
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

