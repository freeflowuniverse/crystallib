module gittools

import freeflowuniverse.crystallib.texttools
import os

fn (mut gitstructure GitStructure) check() ! {
	if gitstructure.status == GitStructureStatus.loaded {
		return
	}
	gitstructure.load()!
}

pub struct GSArgs {
pub mut:
	filter  string // if used will only show the repo's which have the filter string inside
	pull    bool   // means when getting new repo will pull even when repo is already tehre
	force   bool   // means we will force a pull and reset old content	
	message string // if we want to do a default commit with a message	
	// show    bool	
}

// get a list of repo's which are in line to the args
//
// struct GSArgs {
// 	filter  string		//if used will only show the repo's which have the filter string inside
// 	pull    bool		// means when getting new repo will pull even when repo is already tehre
// 	force   bool		// means we will force a pull and reset old content	
//
pub fn (mut gitstructure GitStructure) repos_get(args GSArgs) []GitRepo {
	mut res := []GitRepo{}
	for mut g in gitstructure.repos {
		relpath := g.path_relative()
		if args.filter != '' {
			if relpath.contains(args.filter) {
				// println("$g.addr.name")
				res << g
			}
		} else {
			res << g
		}
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
		changed := g.changes() or { panic('issue in repo changes. $err') }
		pr := g.path_relative()
		if changed {
			r << ['- $pr', '$g.addr.branch', 'CHANGED']
		} else {
			r << ['- $pr', '$g.addr.branch', '']
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

	if !os.exists(gitstructure.codepath()) {
		os.mkdir_all(gitstructure.codepath())!
	}

	gitstructure.check()!
}

// the factory for getting the gitstructure
// git is checked uderneith $/code
fn (mut gitstructure GitStructure) load() ! {
	if gitstructure.status == GitStructureStatus.loaded {
		return
	}

	// print_backtrace()
	// println(' - SCAN GITSTRUCTURE FOR $root2 ')

	// println(" -- multibranch: $multibranch")

	gitstructure.repos = []GitRepo{}

	mut done := []string{}

	// path which git repos will be recursively loaded
	git_path := gitstructure.codepath() + '/github'
	gitstructure.load_recursive(git_path, mut done)!

	gitstructure.status = GitStructureStatus.loaded

	// println(" - SCAN done")
}

fn (mut gitstructure GitStructure) load_recursive(path1 string, mut done []string) ! {
	// println(" - git load: $path1")
	items := os.ls(path1) or { return error('cannot load gitstructure because cannot find $path1') }
	mut pathnew := ''
	for item in items {
		pathnew = os.join_path(path1, item)
		// CAN DO THIS LATER IF NEEDED
		// if pathnew in done{
		// 	continue
		// }
		// done << pathnew
		if os.is_dir(pathnew) {
			// println(" - $pathnew")		
			if os.exists(os.join_path(pathnew, '.git')) {
				gitaddr := addr_get_from_path(pathnew) or { return err }
				gitstructure.repos << GitRepo{
					addr: gitaddr
					path: pathnew
					id: gitstructure.repos.len
					gs: &gitstructure
				}
				continue
			}
			if item.starts_with('.') {
				continue
			}
			if item.starts_with('_') {
				continue
			}
			gitstructure.load_recursive(pathnew, mut done)!
		}
	}
	// println(" - git exit: $path1")
}

pub fn (mut gs GitStructure) codepath() string {
	mut p := ''
	if gs.config.multibranch {
		p = gs.config.root + '/multi'
	} else {
		p = gs.config.root
	}
	// println(" ***** $p")
	return p
}
