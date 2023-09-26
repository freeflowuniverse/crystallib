module gittools

import freeflowuniverse.crystallib.pathlib { Path }
import os
import freeflowuniverse.crystallib.texttools


[params]
pub struct RepoGetArgs{
	locator GitLocator
	pull bool  //if we want to pull when calling the repo
	reset bool //if we want to force a clean repo
}

// will get repo starting from url, if the repo does not exist, only then will pull
// if pull is set on true, will then pull as well
// struct RepoGetFromUrlArgs {
// 	locator GitLocator
// 	pull   bool // will pull if this is set
// 	reset bool //this means will pull and reset all changes
// }
pub fn (mut gitstructure GitStructure) repo_get(args_ RepoGetArgs) !&GitRepo {
	mut args:=args_
	if args.reset{
		args.pull=true
	}
	mut r:=GitRepo{
		addr: args.locator.addr
		gs: &gitstructure
		path: args.locator.addr.path()!
	}
	if !gitstructure.repo_exists(args.locator) {
		// repo does not exist yet
		println(' - repo does not exist yet.\n$l')
		gitstructure.repos << r
	}else{
		r = *gitstructure.get(args.locator)! //get the most recent one, unreference
	}
	r.addr = locator.addr
	return &r
}

fn (mut gitstructure GitStructure) repo_get_internal(l GitLocator) !&GitRepo {
	res := gitstructure.repos_get(name:l.name,account:l.account)!
	if res.len==0{
		return error("cannot find repo with locator.\n${l}")
	}
	if res.len>1{
		return error("Found more than 1 repo with locator.\n${l}")
	}
	if res[0].addr.name != l.name || res[0].name != l.name 
	return res[0]
}


pub fn (mut gitstructure GitStructure) repo_exists(l GitLocator) bool {
	res := gitstructure.repos_get(name:l.name,account:l.account)!
	if res.len==0{
		return false
	}
	if res.len>1{
		return error("Found more than 1 repo with locator.\n${l}")
	}
	return true
}



// get a list of repo's which are in line to the args
//
// struct ReposGetArgs {
// 	filter  string		//if used will only show the repo's which have the filter string inside
//  name string
//  account string
// 	pull    bool		// means when getting new repo will pull even when repo is already there
// 	reset   bool		// means we will force a pull and reset old content	
//
pub fn (mut gitstructure GitStructure) repos_get(args_ GSArgs) []GitRepo {
	mut args:=args_
	args.name = texttools.name_fix(args.name)
	args.account = texttools.name_fix(args.account)
	mut res := []GitRepo{}
	for mut r in gitstructure.repos {
		relpath := r.path_relative()
		if args.filter != '' {
			if relpath.contains(args.filter) {
				// println("$g.name()")
				res << g
			}
		} 
		if args.account.len>0 && args.account!=r.addr.account{
			continue //means no match
		}
		if args.name.len>0 && args.name!=r.addr.name{
			continue //means no match
		}		
		if args.pull{
			r.check(pull:args.pull,reset:args.reset)!
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
pub fn (mut gitstructure GitStructure) repos_print(args GSArgs) {
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

pub fn (mut gitstructure GitStructure) list(args GSArgs) {
	texttools.print_clear()
	println(' #### overview of repositories:')
	println('')
	gitstructure.repos_print(args)
	println('')
}

// reload the full git tree
fn (mut gitstructure GitStructure) reload() ! {
	gitstructure.status = GitStructureStatus.init

	if !os.exists(gitstructure.rootpath) {
		os.mkdir_all(gitstructure.rootpath)!
	}

	gitstructure.check()!
}
