module context

import freeflowuniverse.crystallib.params
import freeflowuniverse.crystallib.ourtime
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.texttools

__global (
	contexts shared map[string]&Context
)

pub struct Context {
pub mut:
	cid    string // unique id per application or a context (an installed app)
	alias  string
	start  ourtime.OurTime
	params params.Params
	done   []string
}

[params]
pub struct ContextNewArgs {
pub mut:
	cid    string // unique id per application or a context (an installed app)
	alias  string
	start  string // can be e.g. +1h
	params ?params.Params
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
	mut args := args_
	args.cid = texttools.name_fix(args.cid)
	if args.cid !in contexts {
		mut params_ := args.params or { params.Params{} }
		mut c := Context{
			cid: args.cid
			alias: args.alias
			start: ourtime.new(args.start)!
			params: params_
		}
		lock contexts {
			contexts[args.cid] = &c
		}
	}
	lock contexts {
		return contexts[args.cid] or { return error('Could not find context ${args.cid}') }
	}
	panic('bug')
}

// save the context to redis & mem
pub fn (mut context Context) load() ! {
	mut r := redisclient.core_get()!
	if context.cid.len == 2 {
		return error('sid should be at least 2 char')
	}
	t := r.hget('context', context.cid)!
	if t == '' {
		return
	}
	p := params.new(t)!
	if context.alias == '' {
		context.alias = p.get_default('alias', '')!
	}
	context.start = p.get_time_default('start', context.start)!
}

// save the context to redis & mem
pub fn (context Context) save() ! {
	mut r := redisclient.core_get()!
	r.hset('context', context.cid, context.str2())!
}

// save the context to redis & mem
pub fn (context Context) str() string {
	return '!!context.context_define ${context.str2()}'
}

fn (context Context) str2() string {
	mut out := 'cid:${context.cid} '
	if context.alias.len > 0 {
		out += ' alias:${context.alias}'
	}
	out += ' start:${context.start}'
	if context.done.len > 0 {
		done := context.done.join(',')
		out += "\n	done:'${done}'"
	}
	return out
}
