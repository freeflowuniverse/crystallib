module gittools

import crypto.md5
import os
import json
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.base
// import freeflowuniverse.crystallib.ui.console

__global (
	gsinstances shared map[string]GitStructure
)

@[heap; params]
pub struct GitStructureConfig {
pub mut:
	key string
	multibranch bool
	coderoot        string // where will the code be checked out, root of code, if not specified comes from context
	light       bool = true // if set then will clone only last history for all branches		
	log         bool   // means we log the git statements
	singlelayer bool   // all repo's will be on 1 level
}

// configure the gitstructure .
// .
// multibranch bool .
// coderoot        string // where will the code be checked out .
// light       bool = true // if set then will clone only last history for all branches		 .
// log         bool   // means we log the git statements .
// .
// has also support for os.environ variables .
// - MULTIBRANCH .
// - DIR_CODE , default: ${os.home_dir()}/code/ .
pub fn new(config_ GitStructureConfig) !GitStructure {
	mut config := config_

	if config.coderoot == '' {
		config.coderoot = '${os.home_dir()}/code'
		config.key = "default"
	}else{
		config.key = md5.hexhash(config.coderoot)
	}

	datajson := json.encode(config)
	mut c := base.context()!
	
	mut redis := c.redis()!
	redis.set(gitstructure_config_key(config.coderoot), datajson)!

	return get(coderoot:config.coderoot)
}

@[params]
pub struct GitStructureGetArgs {
pub mut:
	coderoot string
	reload   bool
}

// params: .
//  - reload  	bool .
pub fn get(args_ GitStructureGetArgs) !GitStructure {
	mut args := args_

	// console.print_debug("GET GS:\n$args")

	gkey:=gitstructure_key(args.coderoot)
	rlock gsinstances {
		if gkey in gsinstances {
			mut gs := gsinstances[gkey] or { panic('bug') }
			if args.reload {
				gs.load()!
			}
			return gs
		}
	}

	mut c := base.context()!
	mut redis := c.redis()!
	mut datajson := redis.get(gitstructure_config_key(args.coderoot))!
	if datajson == '' {
		return error("can't find gitstructure for coderoot: '${args.coderoot}'")
	}
	mut config := json.decode(GitStructureConfig, datajson)!

	mut gs := GitStructure{
		config: config
		coderoot: pathlib.get_dir(path: config.coderoot, create: true) or {
			panic('this should never happen: ${err}')
		}
	}

	gs.load()!

	lock gsinstances {
		gsinstances[gitstructure_config_key(args.coderoot)] = gs
	}

	// println(gs.config)

	return gs
}



////////CACHE

pub fn cachereset(coderoot string) ! {
	mut c := base.context()!
	mut redis := c.redis()!
	keys := redis.keys(gitstructure_cache_key(coderoot))!
	for key in keys {
		// console.print_debug(key)
		redis.del(key)!
	}
}	


pub fn configreset() ! {
	mut c := base.context()!
	mut redis := c.redis()!
	key_check := 'git:config:*'
	keys := redis.keys(key_check)!
	for key in keys {
		redis.del(key)!
	}
}

// reset all caches and configs, for all git repo's .
// can't harm, will just reload everything
pub fn cachereset() ! {
	key_check := 'git:cache:**'
	mut c := base.context()!
	mut redis := c.redis()!	
	keys := redis.keys(key_check)!
	for key in keys {
		redis.del(key)!
	}
	configreset()!
}

