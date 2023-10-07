module gittools

import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.redisclient
import os

[params]
pub struct RepoGetArgs {
pub mut:
	locator GitLocator
	pull    bool // if we want to pull when calling the repo
	reset   bool // if we want to force a clean repo
}

// returns the git address starting from path
fn (mut gitstructure GitStructure) repo_from_path(path string) !&GitRepo {
	mut path2 := path.replace('~', os.home_dir())

	// TODO: walk up to find .git in dir, this way we know we found the right path for the repo

	// println('GIT ADDR ${path2}')
	if !os.exists(os.join_path(path2, '.git')) {
		return error("path: '${path2}' is not a git dir, missed a .git directory")
	}
	pathconfig := os.join_path(path2, '.git', 'config')
	if !os.exists(pathconfig) {
		return error("path: '${path2}' is not a git dir, missed a .git/config file")
	}
	mut redis := redisclient.core_get()!
	mut url:=redis.get('git:cache:${path}:url') or {""}	
	mut branch:=redis.get('git:cache:${path}:branch') or {""}	

	if url==""{
		cmd := 'cd ${path} && git config --get remote.origin.url'
		res := os.execute(cmd)
		if res.exit_code==1{
			return error("Git doesn have an origin url, maybe gitrepo is corrupt. See ${path2}")
		} else if res.exit_code==0{
			url=res.output.trim(' \n')	
			redis.set('git:cache:${path}:url',url) or {}	
			redis.expire('git:cache:${path}:url',1800)!
		}else{
			return error("Cannot get git config. Cmd was:\n$cmd")
		}
	}

	if branch==""{
		cmd2 := 'cd ${path} && git rev-parse --abbrev-ref HEAD'
		branch = os.execute_or_panic(cmd2).output.trim(' \n')
		redis.set('git:cache:${path}:branch',branch) or {}	
		redis.expire('git:cache:${path}:branch',1800)!
	}

	mut locator := gitstructure.locator_new(url)!
	locator.addr.branch = branch

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
	// QUESTION: is this necessary? causes double counting in loading
	// gitstructure.repos << &gitrepo
	return &gitrepo
}

// will get repo starting from url, if the repo does not exist, only then will pull
// if pull is set on true, will then pull as well
pub fn (mut gitstructure GitStructure) repo_get(args_ RepoGetArgs) !&GitRepo {
	mut args := args_
	args.pull = args_.reset || args_.pull

	p := args.locator.addr.path()!
	mut r := gitstructure.repo_from_path(p.path)!
	if args.pull {
		r.check(pull: args.pull, reset: args.reset)!
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
	pull     bool // means when getting new repo will pull even when repo is already there
	reset    bool // means we will force a pull and reset old content	
}

pub fn (mut gitstructure GitStructure) repos_get(args_ ReposGetArgs) []&GitRepo {
	mut args := ReposGetArgs{
		...args_
		name: texttools.name_fix(args_.name)
		account: texttools.name_fix(args_.account)
	}
	mut res := []&GitRepo{}
	for r in gitstructure.repos {
		relpath := r.path_relative()
		if args.filter != '' {
			if relpath.contains(args.filter) {
				// println("$g.name()")
				res << r
			}
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

	// pull found repos if pull arg
	for mut r in res {
		if args.pull {
			r.check(pull: args.pull, reset: args.reset) or { panic('failed to check repo ${err}') }
		}
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
