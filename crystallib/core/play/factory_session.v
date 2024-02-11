module play

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.data.ourtime

@[params]
pub struct PlayArgs {
pub mut:
	context       ?&Context @[skip; str: skip]
	session       ?&Session @[skip; str: skip]
	context_name  string = 'default'
	session_name  string // default will be based on a date when run
	interactive   bool = true // can ask questions, default on true
	coderoot      string // this will define where all code is checked out
	playbook_url  string // url of heroscript to get and execute in current context
	playbook_path string // path of heroscript to get and execute
	playbook_text string // heroscript to execute
	// playbook_priorities map[int]string
}

// return a session which has link to the actions and params on context and session level
// the session also has link to fskvs (filesystem key val stor and gitstructure if relevant)
pub fn session_new(args_ PlayArgs) !&Session {
	mut args := args_

	if args.session != none {
		mut session := args.session or { panic('bug') }
		args.context = &session.context
	}

	if args.context_name.len > 0 {
		if args.context != none {
			return error('cannot have context_name specified and context')
		}
		if args.session != none {
			return error('cannot have context_name specified and session')
		}
	}

	if args.coderoot.len > 0 {
		if args.context != none {
			return error('cannot have coderoot specified and context')
		}
		if args.session != none {
			return error('cannot have coderoot specified and session')
		}
	}

	if args.coderoot.len > 0 {
		if args.context_name.len == 0 {
			return error('if coderoot specified, also need to specify a context_name')
		}
		context_configure(
			coderoot: args.coderoot
			name: args.context_name
			interactive: args.interactive
		)!
	}

	mut context := args.context or {
		mut c := context_get(name: args.context_name, interactive: args.interactive)!
		&c
	}

	mut session := args.session or {
		if args.session_name.len == 0 {
			now := ourtime.now()
			args.session_name = now.key()
		}
		mut session := context.session_new(name: args.session_name)!
		&session
	}

	// session.playbook_priorities = args.playbook_priorities.clone()

	mut plbook := playbook.new(
		text: args.playbook_text
		url: args.playbook_url
		path: args.playbook_path
	) or { panic(err) }

	session.plbook = plbook

	return session
}
