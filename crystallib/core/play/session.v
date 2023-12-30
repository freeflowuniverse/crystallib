module play

import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.data.fskvs
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console

@[heap]
pub struct Session {
pub mut:
	name                string // unique id for session (session id), can be more than one per context
	plbook              playbook.PlayBook
	params              paramsparser.Params
	start               ourtime.OurTime
	end                 ourtime.OurTime
	playbook_priorities map[int]string      @[skip; str: skip]
	context             Context             @[skip; str: skip]
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


//add playbook context to session
//```
// path    string
// text    string
// prio    int = 99
//```	
pub fn (mut session Session) add_playbook(args_ playbook.PLayBookAddArgs) ! {

	mut args := args_

	// walk over directory
	if args.path.len > 0 {
		console.print_header("Session add plbook from path:'${args.path}'")
		mut p := pathlib.get(args.path)
		if !p.exists() {
			return error("can't find path:${p.path}")
		}
		if p.is_file() {
			c := p.read()!
			session.add_playbook(text: c, prio: args.prio)!
			return
		} else if p.is_dir() {
			mut ol := p.list(recursive: true, regex: [r'.*\.md$'])!
			for mut p2 in ol.paths {
				c2 := p2.read()!
				session.add_playbook(text: c2, prio: args.prio)!
			}
			return
		}
		return error("can't process path: ${args.path}, unknown type.")
	}
	console.print_header('Session add plbook add text')
	console.print_stdout(args.text)

	args.text = texttools.dedent(args.text)	
	args.text=session.context.pre_process(text:args.text)!

	session.plbook.add(text:args.text,prio:args.prio)!
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
