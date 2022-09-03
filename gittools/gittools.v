module gittools

import texttools
import os

fn init_gitstructure() GitStructure {
	mut gitstructure := GitStructure{}
	return gitstructure
}

const codecache = init_gitstructure()

fn get_internal() &GitStructure {
	return &gittools.codecache
}

fn (mut gitstructure GitStructure) check() ? {
	if gitstructure.status == GitStructureStatus.loaded {
		return
	}
	gitstructure.load()?
}

pub fn get() ?&GitStructure {
	mut gs := get_internal()

	// initial step
	if gs.status == GitStructureStatus.new {
		if 'MULTIBRANCH' in os.environ() {
			gs.multibranch = true
		}

		if 'DIR_CODE' in os.environ() {
			gs.root = os.environ()['DIR_CODE'] + '/'
		} else {
			gs.root = '$os.home_dir()/code/'
		}

		gs.root = gs.root.replace('~', os.home_dir()).trim_right('/')

		if !os.exists(gs.root) {
			os.mkdir_all(gs.root)?
		}

		gs.status = GitStructureStatus.init // step2
	}

	gs.check()?
	return gs
}

pub struct GSArgs {
pub mut:
	filter  string
	message string
	force   bool
	show    bool
	pull    bool
}

pub fn (mut gitstructure GitStructure) multibranch_set() ? {
	if gitstructure.multibranch {
		return
	}

	gitstructure.multibranch = true
	gitstructure.root = '$os.home_dir()/codemulti/'

	gitstructure.reload()?
}

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

	if !os.exists(gitstructure.root) {
		os.mkdir_all(gitstructure.root)?
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
	gitstructure.load_recursive(gitstructure.root, mut done)?
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
