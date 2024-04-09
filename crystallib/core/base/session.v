module base

import freeflowuniverse.crystallib.data.ourtime
// import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.dbfs
// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.develop.gittools
// import freeflowuniverse.crystallib.ui.console

@[heap]
pub struct Session {
pub mut:
	name        string // unique id for session (session id), can be more than one per context
	interactive bool = true
	params      paramsparser.Params
	start       ourtime.OurTime
	end         ourtime.OurTime
	context     Context             @[skip; str: skip]
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
		context: context
	}
	return s
}

@[params]
pub struct PLayBookAddArgs {
pub mut:
	path      string
	text      string
	git_url   string
	git_pull  bool // will pull if this is set
	git_reset bool // this means will pull and reset all changes	
	prio      int = 10
	run       bool
}

///////// LOAD & SAVE

fn (mut self Session) key() string {
	return 'sessions:${self.guid()}'
}

// get db of the session, is unique per session
pub fn (mut self Session) db_get() !dbfs.DB {
	return self.context.db_get('session_${self.name}')!
}

// get the db of the config, is unique per context
pub fn (mut self Session) db_config_get() !dbfs.DB {
	return self.context.db_get('config')!
}

// load the params from redis
pub fn (mut self Session) load() ! {
	mut r := self.context.redis
	rkey := 'hero:session:params:${self.name}'
	if r.exists(rkey)! {
		paramtxt := r.get(rkey)!
		self.params = paramsparser.new(paramtxt)!
	}
}

// save the params to redis
pub fn (mut self Session) save() ! {
	self.check()!
	mut r := self.context.redis
	rkey := 'hero:session:params:${self.name}'
	r.set(rkey, self.params.str())!
}

////////// REPRESENTATION

pub fn (mut self Session) check() ! {
	if self.name.len < 4 {
		return error('name should be at least 3 char')
	}
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
