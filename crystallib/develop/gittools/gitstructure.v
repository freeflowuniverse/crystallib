module gittools

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.clients.redisclient
// import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console

@[heap]
pub struct GitStructure {
	config GitStructureConfig // configuration settings
pub mut:
	rootpath pathlib.Path = pathlib.get('~/code') // path to root code directory
	repos    []&GitRepo // repositories in gitstructure
}

fn (gs GitStructure) cache_key() string {
	return gitstructure_cache_key(gs.name())
}

pub fn (gs GitStructure) name() string {
	return gs.config.name
}

// remove cache
pub fn (gs GitStructure) cache_reset() ! {
	mut redis := redisclient.core_get()!
	key_check := gs.cache_key()
	keys := redis.keys(key_check)!
	for key in keys {
		redis.del(key)!
	}
}

pub fn (mut gitstructure GitStructure) list(args ReposGetArgs) ! {
	// texttools.print_clear()
	println(' #### overview of repositories:')
	println('')
	gitstructure.repos_print(args)!
	println('')
}

fn (mut gitstructure GitStructure) repo_from_path(path string) !GitRepo {
	// find parent with .git
	mypath := pathlib.get_dir(path: path, create: false)!
	mut parentpath := mypath.parent_find('.git') or {
		return error('cannot find .git in parent starting from: ${path}')
	}
	if parentpath.path == '' {
		return error('cannot find .git in parent starting from: ${path}')
	}
	mut r := GitRepo{
		gs: &gitstructure
		addr: GitAddr{
			gsconfig: gitstructure.config
		}
		path: parentpath
	}
	// println(" - load from path: $parentpath.path")
	r.load_from_path()!
	// println("ok")
	return r
}

// add repository to gitstructure
pub fn (mut gs GitStructure) repo_add(args GSCodeGetFromUrlArgs) !&GitRepo {
	if args.path.len > 0 {
		mut repo := gs.repo_from_path(args.path)!
		// add repo only if there arent duplicates
		if gs.repos.all(it.path.path != repo.path.path) {
			gs.repos << &repo
		}
		return &repo
	}
	mut locator := gs.locator_new(args.url)!
	if args.branch.len > 0 {
		// repo.branch_switch(args.branch)!
		locator.addr.branch = args.branch
	}
	mut repo := gs.repo_get(locator: locator, reset: false, pull: false)!
	if args.sshkey.len > 0 {
		repo.ssh_key_set(args.sshkey)!
	}
	if args.reload {
		repo.load()!
	}
	if args.reset {
		repo.remove_changes()!
	}
	if args.pull {
		repo.pull()!
	}
	// add repo only if there arent duplicates
	if gs.repos.all(it.path.path != repo.path.path) {
		gs.repos << &repo
	}
	return &repo
}

pub struct GSCodeGetFromUrlArgs {
pub mut:
	path   string
	url    string
	branch string
	sshkey string
	pull   bool // will pull if this is set
	reset  bool // this means will pull and reset all changes
	reload bool // reload the cache
}

// will get repo starting from url, if the repo does not exist, only then will pull .
// if pull is set on true, will then pull as well .
// url examples: .
// ```
// https://github.com/threefoldtech/tfgrid-sdk-ts
// https://github.com/threefoldtech/tfgrid-sdk-ts.git
// git@github.com:threefoldtech/tfgrid-sdk-ts.git
//
// # to specify a branch and a folder in the branch
// https://github.com/threefoldtech/tfgrid-sdk-ts/tree/development/docs
//
// args:
// path   string
// url    string
// branch string
// sshkey string
// pull   bool // will pull if this is set
// reset  bool // this means will pull and reset all changes
// reload bool // reload the cache
// ```
pub fn (mut gs GitStructure) code_get(args_ GSCodeGetFromUrlArgs) !string {
	mut args := args_
	console.print_header('code get url:${args.url} or path:${args.path}')
	mut g := gs.repo_add(args)!
	mut locator := gs.locator_new(args.url)!
	s := locator.path_on_fs()!
	return s.path
}
