module gittools

import freeflowuniverse.crystallib.pathlib { Path }
import os
import freeflowuniverse.crystallib.texttools


[heap]
pub struct GitStructure {
pub mut:
	name     string = "default"
	config   GSConfig
	repos    []&GitRepo
	status   GitStructureStatus
	rootpath pathlib.Path
}

[params]
pub struct GitStructureConfig {
pub mut:
 	name        string = "default"
	multibranch bool
	root        string // where will the code be checked out
	light       bool = true // if set then will clone only last history for all branches		
	log         bool   // means we log the git statements
}

pub enum GitStructureStatus {
	new
	init
	loaded
	error
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
			r << ['- ${pr}', '${g.addr().branch}', 'CHANGED']
		} else {
			r << ['- ${pr}', '${g.addr().branch}', '']
		}
	}
	texttools.print_array2(r, '  ', true)
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
	git_path := gitstructure.codepath() 
	if !(os.exists(gitstructure.codepath())) {
		os.mkdir_all(gitstructure.codepath())!
	}

	gitstructure.load_recursive(git_path, mut done)!

	gitstructure.status = GitStructureStatus.loaded

	// println(" - SCAN done")
}

fn (mut gitstructure GitStructure) load_recursive(path1 string, mut done []string) ! {
	mut path1o := pathlib.get(path1)
	relpath := path1o.path_relative(gitstructure.rootpath.path)!
	if relpath.count('/') > 3 {
		return
	}
	// println(" - git load: $relpath")
	items := os.ls(path1) or {
		return error('cannot load gitstructure because cannot find ${path1}')
	}
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
				gitstructure.repos << GitRepo{
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
