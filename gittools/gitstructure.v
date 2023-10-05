module gittools

import os
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools

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
pub fn new(config_ GitStructureConfig) !GitStructure {
	if config_.name == '' {
		return error('need to provide name for gitstructure')
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
	name   string
	create bool // if true, will create a gitstructure
}

pub fn get(args_ GitStructureGetArgs) ?GitStructure {
	name := if args_.name == '' {
		'default'
	} else {
		args_.name
	}

	args := GitStructureGetArgs{
		...args_
		name: name
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

pub fn (mut gitstructure GitStructure) repos_print(args ReposGetArgs) {
	mut r := [][]string{}
	for g in gitstructure.repos_get(args) {
		changed := g.changes() or { panic('issue in repo changes. ${err}') }
		pr := g.path_relative()
		if changed {
			r << ['- ${pr}', '${g.addr.branch}', 'CHANGED']
		} else {
			r << ['- ${pr}', '${g.addr.branch}', '']
		}
	}
	texttools.print_array2(r, '  ', true)
}
