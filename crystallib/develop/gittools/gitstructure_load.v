module gittools

import os
import freeflowuniverse.crystallib.core.pathlib

// the factory for getting the gitstructure
// git is checked uderneith $/code
pub fn (mut gitstructure GitStructure) load() ! {
	// print_backtrace()
	// if true{panic("s")}
	if gitstructure.loaded {
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
	for mut repo in gitstructure.repos {
		repo.status()!
		// console.print_debug(repo)
	}
	gitstructure.loaded = true
	// console.print_debug(' load gitstructure from disk done')
}

fn (mut gitstructure GitStructure) reload() ! {
	gitstructure.loaded = false
	gitstructure.cache_reset()!
	gitstructure.load()!
}

// fn (mut gitstructure GitStructure) reload() ! {
// 	gitstructure.repos.clear()
// 	gitstructure.cache_reset()!
// 	mut done := []string{}
// 	// path which git repos will be recursively loaded
// 	git_path := gitstructure.rootpath
// 	if !(os.exists(gitstructure.rootpath.path)) {
// 		os.mkdir_all(gitstructure.rootpath.path)!
// 	}
// 	gitstructure.load_recursive(git_path.path, mut done)!
// 	for mut repo in gitstructure.repos {		
// 		// console.print_debug(" - ${repo.addr}")
// 		repo.load()!
// 		// repo.status()!
// 		console.print_debug(repo)
// 	}
// }

// // internal function to be executed in thread
// fn repo_refresh(addr GitAddr, path string) {
// 	repo_load(addr, path) or { panic(err) }
// 	// console.print_header(' thread done: ${path}')
// 	// console.print_debug(" ==== ${addr.name}")
// 	// r.load() or {panic(err)}
// }

// pub fn (mut gs GitStructure) reload() ! {

// 	mut done := []string{}
// 	gs.load_recursive(gs.rootpath.path, mut done)!
// 	// mut threads := []thread{}
// 	for mut repo in gs.repos {
// 		// threads<<spawn repo_refresh(repo.addr,repo.path.path)
// 		repo_load(repo.addr,repo.path.path)!
// 		repo.status()!
// 	}
// 	// console.print_debug(" - wait for threads")
// 	// time.sleep(time.Duration(time.second)*10)
// 	// threads.wait()
// 	// console.print_header(' all repo refresh jobs finished.')
// }

fn (mut gitstructure GitStructure) load_recursive(path1 string, mut done []string) ! {
	// $if debug{console.print_debug("gitstructure recursive load: $path1")}
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
		if os.is_dir(pathnew) {
			if os.exists(os.join_path(pathnew, '.git')) {
				mut repo := gitstructure.repo_from_path(pathnew)!
				p := repo.addr.path()!
				if repo.key() in done || p.path in done {
					return error('loading of repo goes wrong found double.\npath:${p.path}\nkey:${repo.key()}')
				}
				done << p.path
				done << repo.key()
				gitstructure.repos << &repo
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
