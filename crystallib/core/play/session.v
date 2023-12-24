module play

import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.data.fskvs

@[heap]
pub struct Session {
pub mut:
	name    string // unique id for session (session id), can be more than one per context
	plbook  playbook.PlayBook
	params  paramsparser.Params
	start   ourtime.OurTime
	end     ourtime.OurTime
	context Context             @[skip; str: skip]
}

@[params]
pub struct SessionNewArgs {
pub mut:
	name        string // unique id for session (session id), there can be more than 1 per id
	start       string // can be e.g. +1h
	load        bool = true // get it from the redis backend
	save        bool
	description string
}

// get a session object based on the name /
// params:
// ```
// name string
// ```
pub fn (context Context) session_new(args_ SessionNewArgs) !Session {
	mut args := args_
	t := ourtime.new(args.start)!
	mut s := Session{
		name: args.name
		start: t
		context: &context
	}

	// if args.load {
	// 	s.load()!
	// }

	// if args.description.len>0 {
	// 	mut params = s.params()!
	// 	params.
	// }

	// if args.save {
	// 	s.save()!
	// }
	return s
}

///////// LOAD & SAVE

fn (mut self Session) key() string {
	return 'sessions:${self.guid()}'
}

fn (mut self Session) db_get(name string) !fskvs.KVS {
	return self.context.kvs.get(name: name)!
}

fn (mut self Session) db_config_get() !fskvs.KVS {
	return self.context.kvs.get(name: 'config')!
}

// save the session to redis & mem
pub fn (mut self Session) load() ! {
	mut r := self.context.redis
	t := r.get(self.key())!
	if t == '' {
		return
	}
	// self.script3_load(t)!
	panic('to implement')
}

// save the self to redis & mem
pub fn (mut self Session) save() ! {
	self.check()!
	mut r := self.context.redis
	r.set(self.key(), self.script3()!)!
	r.expire(self.key(), 3600 * 48)!
}

////////// REPRESENTATION

pub fn (mut self Session) check() ! {
	if self.name.len < 4 {
		return error('name should be at least 3 char')
	}
}

pub fn (mut c Session) str() string {
	return c.script3() or { "BUG: can't represent the object properly." }
}

pub fn (mut c Session) script3() !string {
	mut out := '!!core.session_define ${c.str2()}\n'
	if !c.params.empty() {
		out += '\n!!core.params_session_set\n'
		out += texttools.indent(c.params.script3(), '    ') + '\n'
	}
	if c.plbook.actions.len > 0 {
		out += '${c.plbook}' + '\n'
	}
	return out
}

pub fn (mut self Session) guid() string {
	return '${self.context.guid()}:${self.name}'
}

fn (self Session) str2() string {
	mut out := 'name:${self.name}'
	out += ' start:\'${self.start}\''
	if !self.end.empty() {
		out += ' end:\'${self.end}\''
	}
	return out
}
