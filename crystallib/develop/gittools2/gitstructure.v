module gittools2

import crypto.md5
import os
import json
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.base





//reload all info from disk & remote ssh
// use kwarg: reload: true to make sure we reload everything
pub fn (mut gitstructure GitStructure) status_update(args StatusUpdateArgs) ! {
	gitstructure.load_recursive(gitstructure.coderoot.path,args, done)!
}

// load git structure recursively
fn (mut gitstructure GitStructure) load_recursive(path1 string, args StatusUpdateArgs, mut done []string) ! {
	console.print_debug("gitstructure recursive load: $path1")
	path1o := pathlib.get(path1)
	relpath := path1o.path_relative(gitstructure.coderoot.path)!
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
				mut repo := gitstructure.repo_init_from_path_(pathnew)!
				repo.load()!
				p := repo.gs.coderoot.path!
				if repo.key in done || p in done {
					return error('loading of repo goes wrong found double.\npath:${p}\nkey:${repo.key}')
				}
				done << p
				done << repo.key
				gitstructure.repos[repo.key] = &repo
				continue
			}
			if item.starts_with('.') {
				continue
			}
			if item.starts_with('_') {
				continue
			}
			gitstructure.load_recursive(pathnew, args, mut done)!
		}
	}
}


pub fn (mut gitstructure GitStructure) cachereset() ! {
	mut c := base.context()!
	mut redis := c.redis()!
	keys := redis.keys("git:repos:${gitstructure.key}:**")!
	for key in keys {
		redis.del(key)!
	}
}




//get the repo init from a known path
fn (mut gitstructure GitStructure) repo_init_from_path_(path string) !GitRepo {
	// find parent with .git
	// console.print_debug(" - load from path: $path")
	mypath := pathlib.get_dir(path: path, create: false)!
	mut parentpath := mypath.parent_find('.git') or {
		return error('cannot find .git in parent starting from: ${path}')
	}
	if parentpath.path == '' {
		return error('cannot find .git in parent starting from: ${path}')
	}
	mut ga := GitAddr{
		gsconfig: &gitstructure.config
	}
	mut r := GitRepo{
		gs: &gitstructure
		path: parentpath
		status_remote:GitRepoStatusRemote{}
		status_local :GitRepoStatusLocal{}
		config :GitRepoConfig{}
	}
	return r
}


