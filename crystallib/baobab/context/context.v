module context

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.clients.redisclient
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.baobab.smartid

__global (
	contexts shared map[string]&Context
)

pub struct Context {
pub mut:
	gid   smartid.GID
	alias string
	start ourtime.OurTime
	// end  ourtime.OurTime
	params       ?paramsparser.Params
	gitstructure ?gittools.GitStructure // optional
	done         []string
}

[params]
pub struct ContextNewArgs {
pub mut:
	gid_str      string // rid.cid.oid format
	id           string // e.g. aaa, is 1...6 letter representation of a unique id
	cid_str      string // string representation of cid
	cid_name     string // chosen name of circle
	alias        string
	start        string
	params       ?paramsparser.Params
	gitstructure ?gittools.GitStructure // optional
}

// create context object.
// params: .
// .
// ```
// gid_str string // rid.cid.oid format
// id  string     // e.g. aaa, is 1...6 letter representation of a unique id
// cid_str string //string representation of cid
// cid_name string //chosen name of circle
// alias string
// start string
// params  ?paramsparser.Params
// gitstructure ?gittools.GitStructure // optional
// ```
// for gid use context.gid(...)  .
//
pub fn new(args ContextNewArgs) !&Context {
	mut g := gid(gid_str: args.gid_str, id: args.id, cid_str: args.cid_str, cid_name: args.cid_name)!

	mut c := Context{
		gid: g
		alias: args.alias
		params: args.params
		gitstructure: args.gitstructure
		// start
	}

	return c
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
	args.id = texttools.name_fix(args.id)
	if args.id !in contexts {
		mut params_ := args.params or { paramsparser.Params{} }
		mut c := Context{
			id: args.id
			alias: args.alias
			start: ourtime.new(args.start)!
			params: params_
		}
		lock contexts {
			contexts[args.id] = &c
		}
	}
	lock contexts {
		c := contexts[args.id] or { return error('Could not find context ${args.id}') }
		return c
	}
	panic('bug')
}

// save the context to redis & mem
pub fn (mut context Context) load() ! {
	mut r := redisclient.core_get()!
	if context.id.len == 2 {
		return error('sid should be at least 2 char')
	}
	t := r.hget('context', context.id)!
	if t == '' {
		return
	}
	p := paramsparser.new(t)!
	if context.alias == '' {
		context.alias = p.get_default('alias', '')!
	}
	context.start = p.get_time_default('start', context.start)!
}

// save the context to redis & mem
pub fn (context Context) save() ! {
	mut r := redisclient.core_get()!
	r.hset('context', context.id, context.str2())!
}

// save the context to redis & mem
pub fn (context Context) str() string {
	return '!!context.context_define ${context.str2()}'
}

fn (context Context) str2() string {
	mut out := 'id:${context.id} '
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
