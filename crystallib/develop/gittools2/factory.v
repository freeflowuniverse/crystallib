module gittools2
import freeflowuniverse.crystallib.core.base


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

	mut key:="default"
	if ! args.coderoot == '' {
		key = md5.hexhash(args.coderoot)
	}

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
	mut datajson := redis.get(gitstructure_config_key(args.coderoot))!
	if datajson == '' {
		return error("can't find gitstructure for coderoot: '${args.coderoot}'")
	}
	mut config := json.decode(GitStructureConfig, datajson)!

	mut gs := GitStructure{
		key:key
		config: config
		coderoot: pathlib.get_dir(path: config.coderoot, create: true) or {
			panic('this should never happen: ${err}')
		}
	}

	mut done:=[]string{}
	gs.load_recursive(coderoot.path,done)!

	lock gsinstances {
		gsinstances[gs.key] = &gs
	}

	// println(gs.config)

	return gs
}




////////CACHE


pub fn configreset() ! {
	mut c := base.context()!
	mut redis := c.redis()!
	key_check := 'git:*'
	keys := redis.keys(key_check)!
	for key in keys {
		redis.del(key)!
	}
}

// reset all caches and configs, for all git repo's .
// can't harm, will just reload everything
pub fn cachereset() ! {
	key_check := 'git:**'
	mut c := base.context()!
	mut redis := c.redis()!	
	keys := redis.keys(key_check)!
	for key in keys {
		redis.del(key)!
	}
	configreset()!
}

