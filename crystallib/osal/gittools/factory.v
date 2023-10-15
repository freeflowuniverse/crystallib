module gittools

import freeflowuniverse.crystallib.clients.redisclient
import os
import json
import freeflowuniverse.crystallib.core.pathlib

__global (
	instances shared map[string]GitStructure
)


[params]
pub struct GitStructureConfig {
pub mut:
	name        string = 'default'
	multibranch bool
	root        string // where will the code be checked out, root of code
	light       bool = true // if set then will clone only last history for all branches		
	log         bool   // means we log the git statements
}

fn cache_key(name string)string {
	return 'git:cache:${name}}:'
}

fn cache_delete(name string)! {
	mut redis := redisclient.core_get()!
	redis.del(cache_key(name))!
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

//configure the gitstructure .
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
	cache_delete(config_.name)!
	datajson:=json.encode(config_)
	mut redis := redisclient.core_get()!
	redis.set(cache_key(config_.name),datajson)!
}


[params]
pub struct GitStructureGetArgs {
pub mut:
	name        string = 'default'
	reload  	bool
}

//return a copy of gitstructure .
// params: .
//  - name      string = 'default' .
//  - reload  	bool .
pub fn get(args_ GitStructureGetArgs) !GitStructure {
	for key, i in instances {
		if i.name == args_.name {
			rlock instances {
				mut gs:= instances[key]
				if args_.reload{
					gs.load()!
				}
				return gs
			}
		}
	}		

	mut redis := redisclient.core_get()!
	mut datajson:=redis.get(cache_key(args_.name))!	
	if datajson==""{
		if args_.name=="default"{
			//is the only one we can do by default
			configure()!
			datajson=redis.get(cache_key(args_.name))!	
			if datajson==""{
				panic("bug")
			}
		}else{
			return error("Configure your gitstructure, ${args_.name}, has not been configured yet.")
		}
	}
	config:=json.decode(GitStructureConfig,datajson)!
	return new(config)!
}

pub struct CodeGetFromUrlArgs {
pub mut:
	gitstructure_name string = 'default' // optional, if not mentioned is default
	url               string
	// branch            string
	pull              bool   // will pull if this is set
	reset             bool   // this means will pull and reset all changes
	reload			  bool=true //reload the cache
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
	mut gs := get(name: args.gitstructure_name)!
	mut locator := gs.locator_new(args.url)!
	g := gs.repo_get(locator: locator)!
	if args.reload{
		g.load()!
	}
	if args.reset{
		g.remove_changes()!
	}
	s := locator.path_on_fs()!
	return s.path
}


// get new gitstructure .
// has also support for os.environ variables .
// - MULTIBRANCH .
// - DIR_CODE , default: ${os.home_dir()}/code/ .
fn new(config_ GitStructureConfig) !GitStructure {
	mut config:=config_
	cache_delete(config.name)!
	if config.root == ""{
		root := if 'DIR_CODE' in os.environ() {
			os.environ()['DIR_CODE'] + '/'
		} else if config_.root == '' {
			'${os.home_dir()}/code/'
		} else {
			config_.root
		}
		config.root=root
	}
	config.multibranch = if 'MULTIBRANCH' in os.environ() {true} else {config.multibranch}
	config.root = config.root.replace('~', os.home_dir()).trim_right('/')

	mut gs := GitStructure{
		config: config
		rootpath: pathlib.get_dir(config.root, true) or { panic('this should never happen') }
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
