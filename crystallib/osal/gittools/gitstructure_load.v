module gittools

import os
import freeflowuniverse.crystallib.core.pathlib

// the factory for getting the gitstructure
// git is checked uderneith $/code
fn (mut gitstructure GitStructure) load() ! {
	if gitstructure.status == GitStructureStatus.loaded {
		return
	}

	gitstructure.repos.clear()

	mut done := []string{}

	// path which git repos will be recursively loaded
	git_path := gitstructure.rootpath
	if !(os.exists(gitstructure.rootpath.path)) {
		os.mkdir_all(gitstructure.rootpath.path)!
	}

	gitstructure.load_recursive(git_path.path, mut done)!
	gitstructure.status = GitStructureStatus.loaded
}

fn (mut gitstructure GitStructure) load_recursive(path1 string, mut done []string) ! {
	path1o := pathlib.get(path1)
	relpath := path1o.path_relative(gitstructure.rootpath.path)!
	if relpath.count('/') > 4 {
		return
	}

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
			if os.exists(os.join_path(pathnew, '.git')) {
				mut repo := gitstructure.repo_from_path(pathnew)!
				$if debug {
					println('Loading repository ${repo.addr} from path ${repo.path.path}')
				}
				gitstructure.repos << repo
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
}

pub fn reload(args_ GitStructureGetArgs) !GitStructure {
	args := GitStructureGetArgs{
		...args_
		name: if args_.name == '' {
			'default'
		} else {
			args_.name
		}
	}

	lock instances {
		_ := get(name: args.name) or { return error('erro') }
		instances[args.name].load()!
	}

	return error('Canot find gitstructure with name ${args.name} to reload.')
}
