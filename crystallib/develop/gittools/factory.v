module gittools
import freeflowuniverse.crystallib.core.base
import crypto.md5
import os
import json
import freeflowuniverse.crystallib.core.pathlib

__global (
	gsinstances shared map[string]&GitStructure
)


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
pub fn getset(args_ GitStructureConfig) !&GitStructure {
	mut args := args_

	mut key:=""
	args.coderoot, key = gitstructure_key(args.coderoot)

	if key in gsinstances {	
		return get(coderoot:args_.coderoot)
	}

	datajson := json.encode(args)
	mut c := base.context()!
	
	mut redis := c.redis()!
	redis.set(gitstructure_config_key(key), datajson)!

	return get(coderoot:args_.coderoot)
}

pub fn default() !&GitStructure {

	mut args:=GitStructureConfig{}
	mut key:=""
	args.coderoot, key = gitstructure_key(args.coderoot)

	datajson := json.encode(args)
	mut c := base.context()!
	
	mut redis := c.redis()!
	redis.set(gitstructure_config_key(key), datajson)!

	return get()
}


@[params]
pub struct GitStructureGetArgs {
pub mut:
	coderoot string
	reload   bool
}

// params: .
//  - reload  	bool .
pub fn get(args_ GitStructureGetArgs) !&GitStructure {
	mut args := args_

	// console.print_debug("GET GS:\n$args")
	mut key:=""
	args.coderoot, key = gitstructure_key(args.coderoot)

	rlock gsinstances {
		if key in gsinstances {
			mut gs := gsinstances[key] or { panic('bug') }
			if args.reload {
				gs.load()!
			}
			return gs
		}
	}

	mut c := base.context()!
	mut redis := c.redis()!
	mut datajson := redis.get(gitstructure_config_key(key))!
	if datajson == '' {
		return error("can't find gitstructure for coderoot: '${args.coderoot}'")
	}
	mut config := json.decode(GitStructureConfig, datajson)!

	mut gs := &GitStructure{
		key:key
		config: config
		coderoot: pathlib.get_dir(path: args.coderoot, create: true)!
	}
	gs.load()!

	lock gsinstances {
		gsinstances[gs.key] = gs
	}

	// println(gs.config)

	return gs
}




////////CACHE


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
	key_check := 'git:repos:**'
	mut c := base.context()!
	mut redis := c.redis()!	
	keys := redis.keys(key_check)!
	for key in keys {
		redis.del(key)!
	}
	configreset()!
}


 fn gitstructure_config_key(coderoothashed string) string {

	return 'git:config:${coderoothashed}'

 }

//return coderoot, key
fn gitstructure_key(coderoot_ string) (string, string){
	mut coderoot := coderoot_
 	mut key := "default"
	if coderoot == '' {
		coderoot = '${os.home_dir()}/code'		
	}else{
		key = md5.hexhash(coderoot)
	}
	return coderoot,key
}