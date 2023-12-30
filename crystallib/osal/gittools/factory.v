module gittools

import freeflowuniverse.crystallib.clients.redisclient
import os
import json
import freeflowuniverse.crystallib.core.pathlib
import crypto.md5

__global (
	instances shared map[string]GitStructure
)

@[params]
pub struct GitStructureConfig {
pub mut:
	name        string = 'default'
	multibranch bool
	root        string // where will the code be checked out, root of code
	light       bool = true // if set then will clone only last history for all branches		
	log         bool   // means we log the git statements
}

pub fn cachereset() ! {
	mut redis := redisclient.core_get()!
	key_check := 'git:cache:*'
	keys := redis.keys(key_check)!
	for key in keys {
		redis.del(key)!
	}
}

pub fn configreset() ! {
	mut redis := redisclient.core_get()!
	key_check := 'git:config:*'
	keys := redis.keys(key_check)!
	for key in keys {
		redis.del(key)!
	}
}

// reset all caches and configs, for all git repo's .
// can't harm, will just reload everything
pub fn reset() ! {
	cachereset()!
	configreset()!
}

fn cache_delete(name string) ! {
	mut redis := redisclient.core_get()!
	keys := redis.keys(gitstructure_cache_key(name))!
	for key in keys {
		// println(key)
		redis.del(key)!
	}
}

fn gitstructure_cache_key(name string) string {
	return 'git:cache:${name}'
}

fn gitstructure_config_key(name string) string {
	return 'git:config:${name}'
}

// configure the gitstructure .
// .
// name        string = 'default' .
// multibranch bool .
// root        string // where will the code be checked out .
// light       bool = true // if set then will clone only last history for all branches		 .
// log         bool   // means we log the git statements .
// .
// has also support for os.environ variables .
// - MULTIBRANCH .
// - DIR_CODE , default: ${os.home_dir()}/code/ .
pub fn configure(config_ GitStructureConfig) ! {
	datajson := json.encode(config_)
	mut redis := redisclient.core_get()!
	redis.set(gitstructure_config_key(config_.name), datajson)!
}

@[params]
pub struct GitStructureGetArgs {
pub mut:
	name     string = 'default'
	coderoot string
	reload   bool
}

// return a copy of gitstructure .
// params: .
//  - name      string = 'default' .
//  - reload  	bool .
//  - coderoot    string , if used and name not used will md5 the coderoot as name
pub fn get(args_ GitStructureGetArgs) !GitStructure {
	mut args := args_
	if args.coderoot.len > 0 {
		if args.name == 'default' || args.name == '' {
			args.name = md5.hexhash(args.coderoot)
		}
	}
	// println("GET GS:\n$args")
	for key, i in instances {
		if i.name() == args.name {
			rlock instances {
				mut gs := instances[key]
				if args.reload {
					gs.load()!
				}
				return gs
			}
		}
	}
	mut redis := redisclient.core_get()!
	mut datajson := redis.get(gitstructure_config_key(args.name))!
	if datajson == '' {
		if args.name == 'default' {
			// is the only one we can do by default
			configure()!
			datajson = redis.get(gitstructure_config_key(args.name))!
			if datajson == '' {
				panic('bug')
			}
		} else if args.name == 'tmp' {
			// is the only one we can do by default
			configure(root: '/tmp/code', name: args.name)!
			datajson = redis.get(gitstructure_config_key(args.name))!
			if datajson == '' {
				panic('bug')
			}
		} else if args.coderoot.len > 0 {
			configure(root: args.coderoot, name: args.name)!
			datajson = redis.get(gitstructure_config_key(args.name))!
			if datajson == '' {
				panic('bug')
			}
		} else {
			return error('Configure your gitstructure, ${args.name}, has not been configured yet.')
		}
	}
	config := json.decode(GitStructureConfig, datajson)!
	return new(config)!
}

pub struct CodeGetFromUrlArgs {
pub mut:
	coderoot          string
	gitstructure_name string = 'default' // optional, if not mentioned is default, tmp is another good one
	url               string
	// branch            string
	pull   bool // will pull if this is set
	reset  bool // this means will pull and reset all changes
	reload bool // reload the cache
}

// will get repo starting from url, if the repo does not exist, only then will pull .
// if pull is set on true, will then pull as well .
// url examples: .
// ```
// https://github.com/threefoldtech/tfgrid-sdk-ts
// https://github.com/threefoldtech/tfgrid-sdk-ts.git
// git@github.com:threefoldtech/tfgrid-sdk-ts.git
//
// # to specify a branch and a folder in the branch
// https://github.com/threefoldtech/tfgrid-sdk-ts/tree/development/docs
// ```
pub fn code_get(args CodeGetFromUrlArgs) !string {
	mut gs := get(name: args.gitstructure_name, coderoot: args.coderoot)!
	return gs.code_get(url: args.url, pull: args.pull, reset: args.reset, reload: args.reload)
}

pub fn repo_get(args CodeGetFromUrlArgs) !GitRepo {
	mut gs := get(name: args.gitstructure_name, coderoot: args.coderoot)!
	mut locator := gs.locator_new(args.url)!
	println(locator)
	mut g := gs.repo_get(locator: locator)!
	if args.reload {
		g.load()!
	}
	if args.reset {
		g.remove_changes()!
	}
	return g
}

// get new gitstructure .
// has also support for os.environ variables .
// - MULTIBRANCH .
// - DIR_CODE , default: ${os.home_dir()}/code/ .
fn new(config_ GitStructureConfig) !GitStructure {
	mut config := config_
	if config.root == '' {
		root := if 'DIR_CODE' in os.environ() {
			os.environ()['DIR_CODE'] + '/'
		} else if config_.root == '' {
			'${os.home_dir()}/code/'
		} else {
			config_.root
		}
		config.root = root
	}
	config.multibranch = if 'MULTIBRANCH' in os.environ() { true } else { config.multibranch }
	config.root = config.root.replace('~', os.home_dir()).trim_right('/')

	mut gs := GitStructure{
		config: config
		rootpath: pathlib.get_dir(path: config.root, create: true) or {
			panic('this should never happen: ${err}')
		}
	}

	if os.exists(gs.config.root) {
		gs.load()!
	} else {
		os.mkdir_all(gs.config.root)!
	}

	lock instances {
		instances[gs.config.name] = gs
	}

	return gs
}

@[params]
pub struct GitDirGetArgs {
pub mut:
	path string
}

// look for git dir at (.git location),
// if path not specified will take current path,
// will give error if we can't find the .git location
pub fn git_dir_get(args_ GitDirGetArgs) !string {
	mut args := args_
	if args.path == '' {
		args.path = os.getwd()
	}

	mut curdiro := pathlib.get_dir(path: args.path, create: false)!
	mut parentpath := curdiro.parent_find('.git') or {
		return error('cannot find git dir in ${args.path}')
	}

	return parentpath.path
}
