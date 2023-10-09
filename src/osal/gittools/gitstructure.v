module gittools

import freeflowuniverse.crystallib.clients.redisclient
import os
import freeflowuniverse.crystallib.pathlib

__global (
	instances shared map[string]GitStructure
)

[heap]
pub struct GitStructure {
	config   GitStructureConfig // configuration settings
	rootpath pathlib.Path = pathlib.get('~/code') // path to root code directory
pub mut:
	name   string = 'default' // key indexing global gitstructure
	repos  []&GitRepo // repositories in gitstructure
	status GitStructureStatus
}

pub enum GitStructureStatus {
	new
	init
	loaded
	error
}

[params]
pub struct GitStructureConfig {
pub mut:
	name        string = 'default'
	multibranch bool
	root        string // where will the code be checked out
	light       bool = true // if set then will clone only last history for all branches		
	log         bool   // means we log the git statements
	cachereset  bool
}

pub fn cachereset() ! {
	mut redis := redisclient.core_get()!
	key_check := 'git:cache:*'
	keys := redis.keys(key_check)!
	for key in keys {
		// println(key)
		redis.del(key)!
	}
}

// get new gitstructure .
// has also support for os.environ variables .
// - MULTIBRANCH .
// - DIR_CODE , default: ${os.home_dir()}/code/ .
pub fn new(config_ GitStructureConfig) !GitStructure {
	if config_.name == '' {
		return error('need to provide name for gitstructure')
	}

	if config_.cachereset {
		cachereset()!
	}
	// TODO: document env overwriting
	root := if 'DIR_CODE' in os.environ() {
		os.environ()['DIR_CODE'] + '/'
	} else if config_.root == '' {
		'${os.home_dir()}/code/'
	} else {
		config_.root
	}

	config := GitStructureConfig{
		...config_
		multibranch: 'MULTIBRANCH' in os.environ() || config_.multibranch
		root: root.replace('~', os.home_dir()).trim_right('/')
	}

	mut gs := GitStructure{
		config: config
		rootpath: pathlib.get_dir(config.root, true) or { panic('this should never happen') }
		status: GitStructureStatus.init
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

[params]
pub struct GitStructureGetArgs {
pub mut:
	name   string
	root   string
	create bool // if true, will create a gitstructure
}

pub fn get(args_ GitStructureGetArgs) !GitStructure {
	mut args := args_
	if args.name == '' {
		args.name = 'default'
	}
	if args.root.len > 0 {
		for key, i in instances {
			// TODO: more defensive
			if i.rootpath.path == args.root {
				rlock instances {
					return instances[key]
				}
			}
		}
		if args.create {
			return new(name: args.name, root: args.root)!
		}
		return error('cannot find gitstructure with args.\n${args}')
	}
	if args.name in instances {
		rlock instances {
			return instances[args.name]
		}
	}
	if args.create {
		return new(name: args.name, root: args.root)!
	}
	return error('cannot find gitstructure with args.\n${args}')
}

pub struct CodeGetFromUrlArgs {
pub mut:
	gitstructure_name string = 'default' // optional, if not mentioned is default
	url               string
	branch            string
	pull              bool   // will pull if this is set
	reset             bool   // this means will pull and reset all changes
	root              string // where code will be checked out
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
	mut gs := get(name: args.gitstructure_name, create: true, root: args.root)!
	mut locator := gs.locator_new(args.url)!
	mut repo := gs.repo_get(locator: locator)!
	s := locator.path_on_fs()!
	return s.path
}
