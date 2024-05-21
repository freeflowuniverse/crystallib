module gittools

import crypto.md5
import os
import json
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.base


__global (
	gsinstances shared map[string]GitStructure
)

@[heap; params]
pub struct GitStructureConfig {
pub mut:
	name string = "default"
	multibranch bool
	root        string // where will the code be checked out, root of code, if not specified comes from context
	light       bool = true // if set then will clone only last history for all branches		
	log         bool   // means we log the git statements
	singlelayer bool   // all repo's will be on 1 level
}


// configure the gitstructure .
// .
// multibranch bool .
// root        string // where will the code be checked out .
// light       bool = true // if set then will clone only last history for all branches		 .
// log         bool   // means we log the git statements .
// .
// has also support for os.environ variables .
// - MULTIBRANCH .
// - DIR_CODE , default: ${os.home_dir()}/code/ .
pub fn new(config_ GitStructureConfig) !GitStructure {
	mut config := config_

	datajson := json.encode(config)
	mut c:=base.context()!

	if config.root == "" {
		config.root = c.config.coderoot
	}

    mut redis:=c.redis()!
	redis.set(gitstructure_config_key(config.name), datajson)!

	return get(name:config.name)

}


@[params]
pub struct GitStructureGetArgs {
pub mut:
	coderoot string
	name string = "default"
	reload   bool
}

// params: .
//  - reload  	bool .
pub fn get(args_ GitStructureGetArgs) !GitStructure {
	mut args := args_
	mut c:=base.context()!
	// println("GET GS:\n$args")

	if args.coderoot.len>0{
		args.name=md5.hexhash(args.coderoot)
		gittools.new(name:args.name,root:args.coderoot)!
	}


	gitname := "${c.id()}_${args.name}"
	rlock gsinstances {
		if c.id()in gsinstances {
			mut gs := gsinstances[gitname] or { panic('bug') }
			if args.reload {
				gs.load()!
			}
			return gs
		}
	}
	mut redis:=c.redis()!
	mut datajson := redis.get(gitstructure_config_key(args.name))!
	if datajson == '' {
		if args.name == "default"{
			new()!
			datajson = redis.get(gitstructure_config_key(args.name))!
		}else{
			return error("can't find gitstructure with name ${args.name}")
		}
	}
	mut config := json.decode(GitStructureConfig, datajson)!


	mut mycontext:=base.context()!

	if config.root == "" {
		config.root = mycontext.config.coderoot
	}	

	if config.root==""{
		config.root="${os.home_dir()}/code"
	}

	mut gs := GitStructure{
		config: config
		rootpath: pathlib.get_dir(path: config.root, create: true) or {
			panic('this should never happen: ${err}')
		}
	}

	if os.exists(config.root) {
		gs.load()!
	}

	lock gsinstances {
		gsinstances[gitname] = gs
	}

	return gs	
}

////////CACHE

pub fn cachereset() ! {
	mut c:=base.context()!
    mut redis:=c.redis()!
	key_check := 'git:cache:*'
	keys := redis.keys(key_check)!
	for key in keys {
		redis.del(key)!
	}
}

pub fn configreset() ! {
	mut c:=base.context()!
    mut redis:=c.redis()!
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
	mut c:=base.context()!
    mut redis:=c.redis()!
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

