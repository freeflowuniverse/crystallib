module gittools

import os
import freeflowuniverse.crystallib.pathlib

__global (
	instances shared map[string]GitStructure
)

[heap]
pub struct GitStructure {
pub mut:
	name     string = 'default'
	config   GitStructureConfig
	repos    []&GitRepo
	status   GitStructureStatus
	rootpath pathlib.Path
}

pub enum GitStructureStatus {
	new
	init
	loaded
	error
}

// TODO: figure out
// pub fn (mut gitstructure GitStructure) repos_print(args GSArgs) {
// 	mut r := [][]string{}
// 	for mut g in gitstructure.repos_get(args) {
// 		changed := g.changes() or { panic('issue in repo changes. ${err}') }
// 		pr := g.path_relative()
// 		if changed {
// 			r << ['- ${pr}', '${g.addr.branch}', 'CHANGED']
// 		} else {
// 			r << ['- ${pr}', '${g.addr.branch}', '']
// 		}
// 	}
// 	texttools.print_array2(r, '  ', true)
// }

[params]
pub struct GitStructureConfig {
pub mut:
	name        string = 'default'
	multibranch bool
	root        string // where will the code be checked out
	light       bool = true // if set then will clone only last history for all branches		
	log         bool   // means we log the git statements
}

// get new gitstructure .
// has also support for os.environ variables .
// - MULTIBRANCH .
// - DIR_CODE , default: ${os.home_dir()}/code/ .
pub fn new(config GitStructureConfig) !GitStructure {
	mut gs := GitStructure{
		config: config
	}

	if gs.config.name == '' {
		return error('need to provide name for gitstructure')
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

	gs.rootpath = pathlib.get_dir(gs.config.root, true) or {
		return error('Code root doesnt exist: ${err}')
	}

	gs.status = GitStructureStatus.init // step2

	// TODO: figure out
	// gs.check()!

	lock instances {
		instances[gs.config.name] = gs
	}

	return gs
}

[params]
pub struct GitStructureGetArgs {
	name   string
	create bool // if true, will create a gitstructure
}

pub fn get(args_ GitStructureGetArgs) ?GitStructure {
	args := GitStructureGetArgs{
		...args_
		name: if args_.name == '' {
			'default'
		} else {
			args_.name
		}
	}

	if args.name in instances {
		rlock instances {
			return instances[args.name]
		}
	}
	return none
}

pub struct CodeGetFromUrlArgs {
pub mut:
	gitstructure_name string // optional, if not mentioned is default
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
	mut gs := get(name: args.gitstructure_name) or { new(name: args.gitstructure_name)! }
	mut locator := gs.locator_new(args.url)!
	mut repo := gs.repo_get(locator: locator)!
	repo.check(pull: args.pull, reset: args.reset)!
	// TODO: figure out
	return locator.path
}
