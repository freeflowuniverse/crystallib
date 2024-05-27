module playbook
// import freeflowuniverse.crystallib.ui.console

// add playbook heroscript (starting from path, text or git url)
//```
// path      string
// text      string
// git_url   string
// git_pull  bool // will pull if this is set
// git_reset bool // this means will pull and reset all changes	
// prio      int = 10
// run bool	
//```	
// pub fn (mut session Session) playbook_add(args_ PLayBookAddArgs) ! {
// 	// console.print_debug("playbook add:\n$args_")
// 	session.processed = false
// 	mut args := args_

// 	if args.git_url.len > 0 {
// 		mut gs := session.context.gitstructure()!
// 		args.path = gs.code_get(url: args.git_url, pull: args.git_pull, reset: args.git_reset)!
// 	}

// 	// walk over directory
// 	if args.path.len > 0 {
// 		console.print_header("Session add plbook from path:'${args.path}'")
// 		mut p := pathlib.get(args.path)
// 		if !p.exists() {
// 			return error("can't find path:${p.path}")
// 		}
// 		if p.is_file() {
// 			c := p.read()!
// 			session.playbook_add(text: c, prio: args.prio)!
// 			return
// 		} else if p.is_dir() {
// 			mut ol := p.list(recursive: true, regex: [r'.*\.md$'])!
// 			for mut p2 in ol.paths {
// 				c2 := p2.read()!
// 				session.playbook_add(text: c2, prio: args.prio)!
// 			}
// 			return
// 		}
// 		return error("can't process path: ${args.path}, unknown type.")
// 	}
// 	console.print_header('Session add plbook add text')
// 	console.print_stdout(args.text)

// 	// for internal processing
// 	session.heroscript_preprocess += '\n' + texttools.dedent(args.text)
// 	if args.run {
// 		session.process()!
// 	}
// }

// pub fn (mut session Session) process() ! {
// 	if session.processed {
// 		return
// 	}
// 	console.print_debug('session ${session.name} process')
// 	session.pre_process()!
// 	session.plbook.add(text: session.heroscript_preprocess)!

// 	priorities := {
// 		1:  'core:*'
// 		5:  'sshagent:*'
// 		10: 'gittools:*'
// 		40: 'books:configure'
// 		45: 'book:define'
// 		60: 'books:generate'
// 		70: 'book:edit,book:open'
// 	}

// 	session.playbook_priorities_add(priorities)
// 	session.plbook.filtersort(priorities: session.playbook_priorities)!

// 	mut config_actions := session.plbook.find(filter: 'core.configure')!

// 	for action in config_actions {
// 		mut p := action.params
// 		mut name := ''
// 		if p.exists('name') {
// 			name = p.get_default('name', 'default')!
// 		}
// 		mut interactive := true
// 		if p.exists('interactive') {
// 			interactive = p.get_default_true('interactive')
// 		}
// 		session.context = context_get(name: name, interactive: interactive)!
// 	}

// 	session.processed = true
// }

// // add priorities for the playbook
// pub fn (mut self Session) playbook_priorities_add(prios map[int]string) {
// 	for prio, val in prios {
// 		if prio !in self.playbook_priorities {
// 			self.playbook_priorities[prio] = ''
// 		}
// 		if val.contains(',') {
// 			for item in val.split(',').map(it.trim_space()).filter(it != '') {
// 				if item !in self.playbook_priorities_defined {
// 					self.playbook_priorities[prio] += ',${item}'
// 					self.playbook_priorities_defined << item
// 				}
// 			}
// 		} else {
// 			if val.trim_space() !in self.playbook_priorities_defined {
// 				self.playbook_priorities[prio] += ',${val.trim_space()}'
// 				self.playbook_priorities_defined << val
// 			}
// 		}
// 	}
// }

// pub fn (mut c Session) str() string {
// 	return c.heroscript() or { "BUG: can't represent the object properly." }
// }

// pub fn (mut c Session) heroscript() !string {
// 	mut out := '!!core.session_define ${c.str2()}\n'
// 	if !c.params.empty() {
// 		out += '\n!!core.params_session_set\n'
// 		out += texttools.indent(c.params.heroscript(), '    ') + '\n'
// 	}
// 	if c.plbook.actions.len > 0 {
// 		out += '${c.plbook}' + '\n'
// 	}
// 	return out
// }
