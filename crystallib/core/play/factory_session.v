module play

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.data.ourtime

@[params]
pub struct PlayArgs {
pub mut:
	script3           string
	actions           playbook.PlayBook
	context           ?&Context
	session           ?&Session
	context_name      string = 'default'
	sid      string
	coderoot          string
	interactive       bool
	fsdb_encrypted    bool
	action_name       string   // to filter actions (optional)
	action_actor      string   // to filter actions (optional)
	action_priorities []string // form of 'actorname:actionname' or 'actorname'	
	action_filter     []string // same as priorities but will remove all the ones who don't match in the filter statements
}

// return a session which has link to the actions and params on context and session level
// the session also has link to fskvs (filesystem key val stor and gitstructure if relevant)
pub fn session_new(args_ PlayArgs) !&Session {
	mut args := args_

	if args.script3.len > 0 {
		mut actions:=playbook.parse_playbook(text: args.script3)!
		args.actions = &actions
	}

	mut context := args.context or {
		mut c := new(
			name: args.context_name
			coderoot: args.coderoot
			interactive: args.interactive
			fsdb_encryption: args.fsdb_encrypted
		)!
		&c
	}

	context.actions_execute(mut args.actions)!

	mut session := args.session or {
		if args.sid.len == 0 {
			now := ourtime.now()
			args.sid = now.key()
		}
		mut session := context.session_new(sid: args.sid)!
		&session
	}


	session.actions_execute(mut args.actions)!


	// 	name  string
	// 	actor string
	// 	priorities []string //form of 'actorname:actionname' or 'actorname'
	// 	filter []string //same as priorities but will remove all the ones who don't match in the filter statements	
	mut plbook := args.actions.filter(
		name: args.action_name
		actor: args.action_actor
		priorities: args.action_priorities
		filter: args.action_filter
	)!

	session.actions = plbook

	return session
}
