module gittools

import os
import freeflowuniverse.crystallib.pathlib

__global (
	instances shared map[string]GitStructure
)


// get new gitstructure .
// args .
//```
// pub struct GSConfig {
//  name        string = "default"
// 	multibranch bool
// 	root        string // where will the code be checked out
// 	light       bool   // if set then will clone only last history for all branches		
// 	log         bool   // means we log the git statements
// }
//```
// has also support for os.environ variables .
// - MULTIBRANCH .
// - DIR_CODE , default: ${os.home_dir()}/code/ .
pub fn new(config GitStructureConfig) !GitStructure {
	mut gs := GitStructure{
		config: config
	}

	if gs.config.gitname == '' {
		return error('need to provide gitname for gitstructure')
	}

	if 'MULTIBRANCH' in os.environ() {
		gs.config.multibranch = true
	}

	if 'DIR_CODE' in os.environ() {
		gs.config.root = os.environ()['DIR_CODE'] + '/'
	}
	if gs.config.root == '' {
		gs.config.root = '${os.home_dir()}/code/'
	}

	gs.config.root = gs.config.root.replace('~', os.home_dir()).trim_right('/')

	gs.rootpath = pathlib.get_dir(gs.config.root, true)!

	gs.status = GitStructureStatus.init // step2

	gs.check()!

	lock instances {
		instances[gs.config.gitname] = gs
	}

	return gs
}

[params]
pub struct GitStructureGetArgs {
pub mut:
	name string
}

pub fn get(args_ GitStructureGetArgs) !GitStructure {
	mut args := args_
	if args.name == '' {
		args.name = 'default'
	}
	if args.name in instances {
		rlock instances {
			return instances[args.name]
		}
	} else {
		lock instances {
			instances[args.name] = new(gitname: args.name)!
		}
	}

	return error('Canot find gitstructure with name ${args.gitname}')
}

pub fn reload(args_ GitStructureGetArgs) !GitStructure {
	mut args := args_
	if args.gitname == '' {
		args.gitname = 'default'
	}
	lock instances {
		if args.gitname in instances {
			mut gs := instances[args.gitname]
			gs.repos = []GitRepo{}
			gs.check()!
		}
	}
	return error('Canot find gitstructure with name ${args.gitname} to reload.')
}

pub struct CodeGetFromUrlArgs {
pub mut:
	gitstructure_name string // optional, if not mentioned is default
	url     string
	branch  string
	pull    bool   // will pull if this is set
	reset   bool   // this means will pull and reset all changes
	root    string // where code will be checked out
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
//
// ```
// PARAMS .
// ```
// 	url    string .
// 	pull   bool // will pull if this is set .
// 	reset bool //this means will pull and reset all changes .
// ```
pub fn code_get(args CodeGetFromUrlArgs) !string {
	mut gs := get(name: args.gitstructure_name)!
	mut locator := gitlocator_new(args.url)!
	mut repo := gs.repo_get_from_locator(locator)!
	repo.check(pull:args.pull,reset:args.reset)!
	return locator.path()!
}
