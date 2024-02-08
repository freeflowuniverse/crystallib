module play

import freeflowuniverse.crystallib.data.ourtime
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.data.fskvs
import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.ui.console

@[heap]
pub struct Session {
mut:
	nrtimes_processed           int
	script3_preprocess          string
	processed                   bool
	playbook_priorities_defined []string
pub mut:
	name                string // unique id for session (session id), can be more than one per context
	plbook              playbook.PlayBook
	interactive         bool = true
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

@[params]
pub struct PLayBookAddArgs {
pub mut:
	path      string
	text      string
	git_url   string
	git_pull  bool // will pull if this is set
	git_reset bool // this means will pull and reset all changes	
	prio      int = 10
}

// add playbook context to session
//```
// path    string
// text    string
// prio    int = 99
// url     string
//```	
pub fn (mut session Session) playbook_add(args_ PLayBookAddArgs) ! {
	session.processed = false
	mut args := args_

	if args.git_url.len > 0 {
		mut gs := session.context.gitstructure()!
		args.path = gs.code_get(url: args.git_url, pull: args.git_pull, reset: args.git_reset)!
	}

	// walk over directory
	if args.path.len > 0 {
		console.print_header("Session add plbook from path:'${args.path}'")
		mut p := pathlib.get(args.path)
		if !p.exists() {
			return error("can't find path:${p.path}")
		}
		if p.is_file() {
			c := p.read()!
			session.playbook_add(text: c, prio: args.prio)!
			return
		} else if p.is_dir() {
			mut ol := p.list(recursive: true, regex: [r'.*\.md$'])!
			for mut p2 in ol.paths {
				c2 := p2.read()!
				session.playbook_add(text: c2, prio: args.prio)!
			}
			return
		}
		return error("can't process path: ${args.path}, unknown type.")
	}
	console.print_header('Session add plbook add text')
	console.print_stdout(args.text)

	// for internal processing
	session.script3_preprocess += '\n' + texttools.dedent(args.text)
}

pub fn (mut session Session) process() ! {
	if session.processed {
		return
	}
	println('session ${session.name} process')
	session.pre_process()!
	session.plbook.add(text: session.script3_preprocess)!

	priorities := {
		1:  'core:*'
		5:  'sshagent:*'
		10: 'gittools:*'
		40: 'books:configure'
		45: 'book:define'
		60: 'books:generate'
		70: 'book:edit,book:open'
	}

	session.playbook_priorities_add(priorities)
	session.plbook.filtersort(priorities: session.playbook_priorities)!
	session.processed = true
}

// add priorities for the playbook
pub fn (mut self Session) playbook_priorities_add(prios map[int]string) {
	for prio, val in prios {
		if prio !in self.playbook_priorities {
			self.playbook_priorities[prio] = ''
		}
		if val.contains(',') {
			for item in val.split(',').map(it.trim_space()).filter(it != '') {
				if item !in self.playbook_priorities_defined {
					self.playbook_priorities[prio] += ',${item}'
					self.playbook_priorities_defined << item
				}
			}
		} else {
			if val.trim_space() !in self.playbook_priorities_defined {
				self.playbook_priorities[prio] += ',${val.trim_space()}'
				self.playbook_priorities_defined << val
			}
		}
	}
}

///////// LOAD & SAVE

fn (mut self Session) key() string {
	return 'sessions:${self.guid()}'
}

// get db of the session, is unique per session
fn (mut self Session) db_get() !fskvs.DB {
	return self.context.db_get('session_${self.name}')!
}

// get the db of the config, is unique per context
fn (mut self Session) db_config_get() !fskvs.DB {
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
