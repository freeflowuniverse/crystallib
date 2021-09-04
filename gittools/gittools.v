module gittools

import os

fn init_gitstructure() GitStructure {
	mut gitstructure := GitStructure{}
	return gitstructure
}

const codecache = init_gitstructure()

pub fn get() &GitStructure {
	return &gittools.codecache
}

pub fn new() ?&GitStructure {
	mut gs := get()
	gs.load() ?
	return gs
}

fn (mut gitstructure GitStructure) check() ? {
	if gitstructure.status == GitStructureStatus.loaded {
		return
	}
	gitstructure.load() ?
}

// the factory for getting the gitstructure
// git is checked uderneith $/code
pub fn (mut gitstructure GitStructure) load() ? {
	mut root2:=""
	if 'DIR_CODE' in os.environ() {
		dir_ct := os.environ()['DIR_CODE']
		root2 = '$dir_ct/'
	} else {
		root2 = '$os.home_dir()/code/'
		if !os.exists(root2) {
			os.mkdir_all(root2) ?
		}
	}

	mut multibranch := false
	if 'MULTIBRANCH' in os.environ() {
		multibranch = true
	}

	root2 = root2.replace('~', os.home_dir()).trim_right("/")

	// check if there are other arguments used as the ones loaded
	if gitstructure.status == GitStructureStatus.loaded {
		if root2 != gitstructure.root {
			gitstructure.status = GitStructureStatus.init
		}
		if multibranch != gitstructure.multibranch {
			gitstructure.status = GitStructureStatus.init
		}
	}

	if gitstructure.status == GitStructureStatus.loaded {
		return
	}

	// print_backtrace()
	println(' - SCAN GITSTRUCTURE FOR $root2 ')

	gitstructure.root = root2
	gitstructure.multibranch = multibranch

	gitstructure.repos = []GitRepo{}

	mut done := []string{}
	gitstructure.load_recursive(gitstructure.root, mut done) ?
	gitstructure.status = GitStructureStatus.loaded

	println(" - SCAN done")
}

fn (mut gitstructure GitStructure) load_recursive(path1 string, mut done []string) ? {
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
					gitstructure: &gitstructure
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
			gitstructure.load_recursive(pathnew, mut done) ?
		}
	}
}

