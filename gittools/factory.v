module gittools

import freeflowuniverse.crystallib.texttools
import os

fn (mut gitstructure GitStructure) check() ? {
	if gitstructure.status == GitStructureStatus.loaded {
		return
	}
	gitstructure.load()?
}

pub struct GSConfig {
pub mut:
	filter      string
	multibranch bool
	root        string // where will the code be checked out
	pull        bool   // means we will pull even if the directory exists
	reset       bool   // be careful, this means we will reset when pulling
	light       bool   // if set then will clone only last history for all branches		
	log         bool   // means we log the git statements
}

// struct GSConfig{
// filter string
// multibranch bool
// root string	//where will the code be checked out
// pull bool   //means we will pull even if the directory exists
// reset bool  //be careful, this means we will reset when pulling
// light       bool  // if set then will clone only last history for all branches		
// }
pub fn get(config GSConfig) ?GitStructure {
	println('*************')
	mut gs := GitStructure{
		config: config
	}

	if 'MULTIBRANCH' in os.environ() {
		gs.config.multibranch = true
	}

	if 'DIR_CODE' in os.environ() {
		gs.config.root = os.environ()['DIR_CODE'] + '/'
	}
	if gs.config.root == '' {
		gs.config.root = '$os.home_dir()/code/'
	}

	gs.config.root = gs.config.root.replace('~', os.home_dir()).trim_right('/')

	if !os.exists(gs.config.root) {
		os.mkdir_all(gs.config.root)?
	}

	gs.status = GitStructureStatus.init // step2

	gs.check()?
	return gs
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
		// println(g)
		changed := g.changes() or { panic('issue in repo changes. $err') }
		if changed {
			r << ['- $g.path_relative()', '$g.addr.branch', 'CHANGED']
		} else {
			// println( " - ${g.path_relative()} - $g.addr.branch")
			r << ['- $g.path_relative()', '$g.addr.branch', '']
		}
	}
	texttools.print_array2(r, '  ', true)
}

pub fn (mut gitstructure GitStructure) list(args GSArgs) ? {
	texttools.print_clear()
	println(' #### overview of repositories:')
	println('')
	gitstructure.repos_print(args)
	println('')
}

// reload the full git tree
fn (mut gitstructure GitStructure) reload() ? {
	gitstructure.status = GitStructureStatus.init

	if !os.exists(gitstructure.codepath()) {
		os.mkdir_all(gitstructure.codepath())?
	}

	gitstructure.check()?
}

// the factory for getting the gitstructure
// git is checked uderneith $/code
fn (mut gitstructure GitStructure) load() ? {
	if gitstructure.status == GitStructureStatus.loaded {
		return
	}

	// print_backtrace()
	// println(' - SCAN GITSTRUCTURE FOR $root2 ')

	// println(" -- multibranch: $multibranch")

	gitstructure.repos = []GitRepo{}

	mut done := []string{}
	gitstructure.load_recursive(gitstructure.codepath(), mut done)?
	gitstructure.status = GitStructureStatus.loaded

	// println(" - SCAN done")
}

fn (mut gitstructure GitStructure) load_recursive(path1 string, mut done []string) ? {
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
			gitstructure.load_recursive(pathnew, mut done)?
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
