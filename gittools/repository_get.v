module gittools

import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.redisclient
import freeflowuniverse.crystallib.osal

import os

[params]
pub struct RepoGetArgs {
pub mut:
	locator GitLocator
	pull    bool // if we want to pull when calling the repo
	reset   bool // if we want to force a clean repo
}


[params]
struct DiskStatusArgs{
pub mut:
	path string
	reload bool
	reload_status bool
}


struct DiskStatus{
mut:
	branch string
	url string 
	status string
}

//load the info from dis
fn repo_disk_status(args DiskStatusArgs) !DiskStatus {
	if args.path.len<3{
		panic("path cannot be smaller than 3.\n$args")
	}
	pre:='git:cache:${args.path}'
	path:=args.path
	mut redis := redisclient.core_get()!
	mut ds:= DiskStatus	{
		url:redis.get('${pre}:url') or {""}	
		branch:redis.get('${pre}:branch') or {""}
		status:redis.get('${pre}:status') or {""}
	}

	if args.reload || ds.url==""{
		cmd := 'cd ${path} && git config --get remote.origin.url'
		ds.url=osal.execute_silent(cmd) or {
			return error('Cannot get remote origin url: ${path}. Error was ${err}')
		}		
		ds.url=ds.url.trim(' \n')
		redis.set('${pre}:url',ds.url) or {}	
		redis.expire('${pre}:url',3600*20)!
	}

	if args.reload || ds.branch==""{
		cmd2 := 'cd ${path} && git rev-parse --abbrev-ref HEAD'
		ds.branch=osal.execute_silent(cmd2) or {
			return error('Cannot get branch: ${path}. Error was ${err}')
		}	
		ds.branch=ds.branch.trim(' \n')
		redis.set('${pre}:branch',ds.branch) or {}	
		redis.expire('${pre}:branch',3600*20)!
	}

	if args.reload || args.reload_status ||  ds.status==""{
		println(" - get status for: ${path}")
		cmd3 := 'cd ${path} &&  git status'
		ds.status=osal.execute_silent(cmd3) or {
			return error('Cannot get status for repo: ${path}. Error was ${err}')
		}		
		redis.set('${pre}:status',ds.status) or {}	
		redis.expire('${pre}:status',3600*20)!
	}

	return ds
}

fn repo_disk_status_delete(args DiskStatusArgs) ! {
	pre:='git:cache:${args.path}:*'
	mut redis := redisclient.core_get()!
		keys := redis.keys(pre)!
		for key in keys {
			redis.del(key)!
		}
}

// returns the git address starting from path
pub fn (mut gitstructure GitStructure) repo_from_path(path string) !&GitRepo {

	if path.len<3{
		panic("path cannot be <3.\n$path")
	}

	mut path2 := path.replace('~', os.home_dir())

	// TODO: walk up to find .git in dir, this way we know we found the right path for the repo

	// println('GIT ADDR ${path2}')
	if !os.exists(os.join_path(path2, '.git')) {
		return error("failed to get repo from path: '${path2}' is not a git dir, missed a .git directory")
	}
	pathconfig := os.join_path(path2, '.git', 'config')
	if !os.exists(pathconfig) {
		return error("path: '${path2}' is not a git dir, missed a .git/config file")
	}

	ds:=repo_disk_status(path:path2)!

	mut locator := gitstructure.locator_new(ds.url)!
	locator.addr.branch = ds.branch

	mut repos := gitstructure.repos_get(
		provider: locator.addr.provider
		account: locator.addr.account
		name: locator.addr.name
	)

	if repos.len > 1 {
		return error('found more than 1 repo in gitructure for same provider/account/name.\npath:${path}\n${repos}')
	}

	if repos.len == 1 {
		// now need to check path is same
		mut r := repos[0]
		mut path2o := pathlib.get_dir(path2, false)!
		if r.path != path2o {
			return error('path mismatch in gitstructure.\npath:${path}\n${repos}')
		}
		return repos[0]
	}
	mut gitrepo := GitRepo{
		path: pathlib.get(path2)
		id: gitstructure.repos.len
		gs: &gitstructure
		addr: *locator.addr
	}
	return &gitrepo
}

// will get repo starting from url, if the repo does not exist, only then will pull
// if pull is set on true, will then pull as well
pub fn (mut gitstructure GitStructure) repo_get(args_ RepoGetArgs) !&GitRepo {
	mut args := args_
	args.pull = args_.reset || args_.pull

	p := args.locator.addr.path()!

	mut r := if gitstructure.repo_exists(args.locator)! {
		gitstructure.repo_from_path(p.path)!
	} else {
		// println("repo does not exist:\n$p\n+++")
		// if repo doesn't exist, create new repo from address in locator
		mut r2:=&GitRepo{
			gs: &gitstructure
			addr: args.locator.addr
			path: p
		}
		r2.checkinit(pull: args.pull, reset: args.reset)!
		gitstructure.repo_from_path(r2.path.path)!
	}
	return r
}

fn (mut gitstructure GitStructure) repo_get_internal(l GitLocator) !&GitRepo {
	res := gitstructure.repos_get(name: l.addr.name, account: l.addr.account)
	if res.len == 0 {
		return error('cannot find repo with locator.\n${l}')
	}
	if res.len > 1 {
		return error('Found more than 1 repo with locator.\n${l}')
	}
	if res[0].addr.name != l.addr.name || res[0].addr.name != l.addr.name {
		// TODO: figure out
	}
	return res[0]
}

pub fn (mut gitstructure GitStructure) repo_exists(l GitLocator) !bool {
	res := gitstructure.repos_get(name: l.addr.name, account: l.addr.account)
	if res.len == 0 {
		return false
	}
	if res.len > 1 {
		return error('Found more than 1 repo with locator.\n${l}')
	}
	return true
}

// get a list of repo's which are in line to the args
//
[params]
pub struct ReposGetArgs {
pub mut:
	filter   string // if used will only show the repo's which have the filter string inside
	name     string
	account  string
	provider string
}

pub fn (mut gitstructure GitStructure) repos_get(args_ ReposGetArgs) []&GitRepo {
	mut args := ReposGetArgs{
		...args_
		name: texttools.name_fix(args_.name)
		account: texttools.name_fix(args_.account)
	}
	mut res := []&GitRepo{}
	// println(args)
	for r in gitstructure.repos {
		relpath := r.path_relative()
		if args.filter != '' {
			if relpath.contains(args.filter) {
				// println("MATCH: $args.filter")
				res << r
			}
			continue
		}
		if args.name.len > 0 && args.name != r.addr.name {
			continue // means no match
		}
		if args.account.len > 0 && args.account != r.addr.account {
			continue // means no match
		}
		if args.provider.len > 0 && args.provider != r.addr.provider {
			continue // means no match
		}
		res << r
	}

	return res
}

pub fn (mut gitstructure GitStructure) list(args ReposGetArgs) {
	texttools.print_clear()
	println(' #### overview of repositories:')
	println('')
	gitstructure.repos_print(args)
	println('')
}
