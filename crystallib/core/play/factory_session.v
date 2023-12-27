module play

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.data.ourtime

@[params]
pub struct PlayArgs {
pub mut:
	script3               string
	context               ?&Context
	session               ?&Session
	context_name          string = 'default'
	session_name          string
	coderoot              string
	interactive           bool
	fsdb_encrypted        bool
	playbook_priorities   map[int]string // filter and give priority
	playbook_core_execute bool = true // executes ssh & git actions
}

// return a session which has link to the actions and params on context and session level
// the session also has link to fskvs (filesystem key val stor and gitstructure if relevant)
pub fn session_new(args_ PlayArgs) !&Session {
	mut args := args_

	mut plbook := playbook.new(text: args.script3)!

	mut context := args.context or {
		mut c := new(
			name: args.context_name
			coderoot: args.coderoot
			interactive: args.interactive
			fsdb_encryption: args.fsdb_encrypted
		)!
		&c
	}

	context.playbook_core_execute(mut plbook)!

	mut session := args.session or {
		if args.session_name.len == 0 {
			now := ourtime.now()
			args.session_name = now.key()
		}
		mut session := context.session_new(name: args.session_name)!
		&session
	}



	session.plbook = plbook

	session.plbook.filtersort(priorities: args.playbook_priorities)!

	if args.playbook_core_execute {
		session.play_ssh()!
		session.play_git()!
	}

	return session
}
