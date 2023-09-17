module context

import freeflowuniverse.crystallib.params
import freeflowuniverse.crystallib.ourtime
import freeflowuniverse.crystallib.redisclient
import freeflowuniverse.crystallib.texttools


__global (
	contexts shared map[string]&Context
)

pub struct Context{
pub mut:
	cid string //unique id per application or a context (an installed app)
	alias string
	start 	ourtime.OurTime
	params params.Params
	done map[string]bool
	redis string
}

[params]
pub struct ContextNewArgs{
pub mut:
	cid string //unique id per application or a context (an installed app)
	alias string
	start string //can be e.g. +1h
	params ?params.Params
	redis string
}


// get a context object based on the name /
// params:
//
// ```
// uid	string //unique id
// name string
// start string  //can be e.g. +1h
// ```
//
pub fn get(args_ ContextNewArgs) !&Context {
	mut args:=args_
	args.cid=texttools.name_fix(args.cid)
	if !(args.cid in contexts){
		mut params_ := args.params or {	params.Params{}		}
		mut r:=redisclient.get("localhost:7777")!
		if args.redis.len>0{
			r=redisclient.get(args.redis)!
		}
		mut c:=Context{
				cid:args.cid
				alias:args.alias
				start:ourtime.new(args.start)!
				params:params_
				redis:r
			}
		lock contexts {
			contexts[args.cid]=&c
		}
	}
	lock contexts {
		return contexts[args.cid] or { return error('Could not find context ${args.cid}') }
	}
	panic('bug')
}

