module context

import freeflowuniverse.crystallib.params
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.ourtime
import freeflowuniverse.crystallib.redis

import os

__global (
	contexts shared map[string]Context
)

pub struct Context{
pub mut:
	cid string //unique id per application or a context (an installed app)
	name string
	start 	timetools.OurTime
	end timetools.OurTime
	params params.Params
	done map[string]bool
	redis redis.Redis
	sessions map[string]Session
}

[params]
pub struct ContextNewArgs{
pub mut:
	cid string //unique id per application or a context (an installed app)
	name string
	start string //can be e.g. +1h
	params ?params.Params
	redis_connection string
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
pub fn get(args_ ContextNewArgs) !Context {
	mut args:=args_
	args.name=texttools.name_fix(args.name)
	if !(args.name in contexts){
		mut params:=params.Params{}
		if args.params{
			params=args.params
		}
		mut r=redis.get("localhost:7777")!
		if args.redisconnection{
			r=redis.get(args.redis_connection)!
		}

		mut c:=Context{
				cid:args.cid
				name:args.name
				start:args.start
				params:params
				redis:r
			}

		lock contexts {
			contexts[args.name]=c
		}
	}
	rlock contexts {
		return contexts[args.name] or { return error('Could not find context ${args.name}') }
	}
	panic('bug')
}

