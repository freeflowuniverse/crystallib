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

fn (gs GitStructure) name() string {
	return gs.config.name
}

// remove cache
fn (gs GitStructure) cache_reset() ! {
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

pub fn (mut gitstructure GitStructure) repo_from_path(path string) !GitRepo {
	mut r := GitRepo{
		gs: &gitstructure
		addr: GitAddr{
			gsconfig: gitstructure.config
		}
		path: pathlib.get_dir(path: path)!
	}
	// r.load_from_path()!
	return r
}

pub struct RepoAddArgs {
pub mut:
	url    string
	branch string
	sshkey string
	pull   bool = true
}

// add repository to gitstructure
pub fn (mut gs GitStructure) repo_add(args RepoAddArgs) ! {
	mut locator := gs.locator_new(args.url)!
	if args.branch.len > 0 {
		// repo.branch_switch(args.branch)!
		locator.addr.branch = args.branch
	}
	if gs.repo_exists(locator)! {
		return
	}
	mut repo := gs.repo_get(locator: locator, reset: false, pull: false)!
	if args.sshkey.len > 0 {
		repo.ssh_key_set(args.sshkey)!
	}
	if args.pull {
		repo.pull()!
	}
	gs.repos << &repo
}

pub struct GSCodeGetFromUrlArgs {
pub mut:
	url    string
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
// url               string
// pull   bool 		 // will pull if this is set
// reset  bool // this means will pull and reset all changes
// reload bool // reload the cache
// ```
pub fn (mut gs GitStructure) code_get(args GSCodeGetFromUrlArgs) !string {
	console.print_header('code get ${args.url}')
	mut locator := gs.locator_new(args.url)!
	// println(locator)
	mut g := gs.repo_get(locator: locator)!
	if args.reload {
		g.load()!
	}
	if args.reset {
		g.remove_changes()!
	}
	if args.pull {
		g.pull()!
	}
	s := locator.path_on_fs()!
	return s.path
}
