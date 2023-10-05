module gittools

import freeflowuniverse.crystallib.pathlib
import os
import freeflowuniverse.crystallib.texttools

[params]
pub struct RepoGetArgs {
	locator GitLocator
	pull    bool // if we want to pull when calling the repo
	reset   bool // if we want to force a clean repo
}


// returns the git address starting from path
fn (gitstructure GitStructure) repo_from_path(path string) !GitAddr {
	mut path2 := path.replace('~', os.home_dir())

	// TODO: walk up to find .git in dir, this way we know we found the right path for the repo

	println('GIT ADDR ${path2}')
	if !os.exists(os.join_path(path2, '.git')) {
		return error("path: '${path2}' is not a git dir, missed a .git directory")
	}
	pathconfig := os.join_path(path2, '.git', 'config')
	if !os.exists(pathconfig) {
		return error("path: '${path2}' is not a git dir, missed a .git/config file")
	}

	cmd := 'cd ${path} && git config --get remote.origin.url'
	url := os.execute_or_panic(cmd).output.trim(' \n')

	cmd2 := 'cd ${path} && git rev-parse --abbrev-ref HEAD'
	branch := os.execute_or_panic(cmd2).output.trim(' \n')

	mut locator := gitstructure.locator_new(url)!
	locator.addr.branch = branch

	repos_get	

	mut gitrepo:=GitRepo{
		path: pathlib.get(pathnew)
		id: gitstructure.repos.len
		gs: &gitstructure
		addr : [locator.addr]
	}	

	return gitrepo
}


// will get repo starting from url, if the repo does not exist, only then will pull
// if pull is set on true, will then pull as well
// struct RepoGetFromUrlArgs {
// 	locator GitLocator
// 	pull   bool // will pull if this is set
// 	reset bool //this means will pull and reset all changes
// }
pub fn (mut gitstructure GitStructure) repo_get(args_ RepoGetArgs) !&GitRepo {
	mut args := RepoGetArgs{
		...args_
		pull: args_.reset || args_.pull
	}

	return gitstructure. args.locator.addr.path()!
	return &r
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
	return &res[0]
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
struct ReposGetArgs {
	filter  string // if used will only show the repo's which have the filter string inside
	name    string
	account string
	pull    bool // means when getting new repo will pull even when repo is already there
	reset   bool // means we will force a pull and reset old content	
}

pub fn (mut gitstructure GitStructure) repos_get(args_ ReposGetArgs) []GitRepo {
	mut args := ReposGetArgs{
		...args_
		name: texttools.name_fix(args_.name)
		account: texttools.name_fix(args_.account)
	}
	mut res := []GitRepo{}
	for mut r in gitstructure.repos {
		relpath := r.path_relative()
		if args.filter != '' {
			if relpath.contains(args.filter) {
				// println("$g.name()")
				res << r
			}
		}
		if args.account.len > 0 && args.account != r.addr.account {
			continue // means no match
		}
		if args.name.len > 0 && args.name != r.addr.name {
			continue // means no match
		}
		if args.pull {
			r.check(pull: args.pull, reset: args.reset) or { panic('failed to check repo ${err}') }
		}
		res << r
	}
	return res
}

// print the repos
//
// struct GSArgs {
// 	filter  string		//if used will only show the repo's which have the filter string inside
// 	pull    bool		// means when getting new repo will pull even when repo is already tehre
// 	force   bool		// means we will force a pull and reset old content	
//
pub fn (mut gitstructure GitStructure) repos_print(args ReposGetArgs) {
	mut r := [][]string{}
	for mut g in gitstructure.repos_get(args) {
		changed := g.changes() or { panic('issue in repo changes. ${err}') }
		pr := g.path_relative()
		if changed {
			r << ['- ${pr}', '${g.addr.branch}', 'CHANGED']
		} else {
			r << ['- ${pr}', '${g.addr.branch}', '']
		}
	}
	texttools.print_array2(r, '  ', true)
}

pub fn (mut gitstructure GitStructure) list(args ReposGetArgs) {
	texttools.print_clear()
	println(' #### overview of repositories:')
	println('')
	gitstructure.repos_print(args)
	println('')
}

// reload the full git tree
fn (mut gitstructure GitStructure) reload() ! {
	gitstructure.status = GitStructureStatus.init

	if !os.exists(gitstructure.rootpath.path) {
		os.mkdir_all(gitstructure.rootpath.path)!
	}

	// TODO: figure out
	// gitstructure.check()!
}
