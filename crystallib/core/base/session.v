module base

import freeflowuniverse.crystallib.data.ourtime
// import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.dbfs
import json
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
	context     &Context            @[skip; str: skip]
	config      SessionConfig
}

@[params]
pub struct SessionConfig {
pub mut:
	name        string // unique name for session (id), there can be more than 1 session per context
	start       string // can be e.g. +1h
	description string
	params      string
}

// get a session object based on the name /
// params:
// ```
// name string
// ```
pub fn (mut context Context) session_new(args_ SessionConfig) !Session {
	mut args := args_
	if args.name == '' {
		args.name = ourtime.now().key()
	}

	if args.start == '' {
		t := ourtime.new(args.start)!
		args.start = t.str()
	}

	mut r := context.redis()!

	rkey := 'sessions:config:${args.name}'

	config_json := json.encode(args)

	r.set(rkey, config_json)!

	rkey_latest := 'sessions:config:latest'
	r.set(rkey_latest, args.name)!

	return context.session_get(name: args.name)!
}

@[params]
pub struct ContextSessionGetArgs {
pub mut:
	name string
}

pub fn (mut context Context) session_get(args_ ContextSessionGetArgs) !Session {
	mut args := args_
	mut r := context.redis()!

	if args.name == '' {
		rkey_latest := 'sessions:config:latest'
		args.name = r.get(rkey_latest)!
	}
	rkey := 'sessions:config:${args.name}'
	mut datajson := r.get(rkey)!
	if datajson == '' {
		if args.name == '' {
			return context.session_new()!
		} else {
			return error("can't find session with name ${args.name}")
		}
	}
	config := json.decode(SessionConfig, datajson)!
	t := ourtime.new(config.start)!
	mut s := Session{
		name: args.name
		start: t
		context: &context
		params: paramsparser.new(config.params)!
		config: config
	}
	return s
}

pub fn (mut context Context) session_latest() !Session {
	mut r := context.redis()!
	rkey_latest := 'sessions:config:latest'
	latestname := r.get(rkey_latest)!
	if latestname == '' {
		return context.session_new()!
	}
	return context.session_get(name: latestname)!
}

///////// LOAD & SAVE

// fn (mut self Session) key() string {
// 	return 'hero:sessions:${self.guid()}'
// }

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
	mut r := self.context.redis()!
	rkey := 'sessions:config:${self.name}'
	mut datajson := r.get(rkey)!
	if datajson == '' {
		return error("can't find session with name ${self.name}")
	}
	self.config = json.decode(SessionConfig, datajson)!
	self.params = paramsparser.new(self.config.params)!
}

// save the params to redis
pub fn (mut self Session) save() ! {
	self.check()!
	rkey := 'sessions:config:${self.name}'
	mut r := self.context.redis()!
	self.config.params = self.params.str()
	config_json := json.encode(self.config)
	r.set(rkey, config_json)!
}

////////// REPRESENTATION

pub fn (mut self Session) check() ! {
	if self.name.len < 3 {
		return error('name should be at least 3 char')
	}
}

// pub fn (mut self Session) guid() string {
// 	return '${self.context.guid()}:${self.name}'
// }

fn (self Session) str2() string {
	mut out := 'name:${self.name}'
	out += ' start:\'${self.start}\''
	if !self.end.empty() {
		out += ' end:\'${self.end}\''
	}
	return out
}
