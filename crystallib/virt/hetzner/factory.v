module hetzner

import encoding.base64
import freeflowuniverse.crystallib.ui as gui
import freeflowuniverse.crystallib.core.base

// import os
// import json
// import net
// import time
// import net.http
// import maxux.vssh

// struct Boot {
// 	rescue Rescue
// }

// struct BootRoot {
// 	boot Boot
// }

@[params]
pub struct ClientArgsGet {
pub mut:
	instance string = 'default'
	session  ?&base.Session
}

pub fn get(args_ ClientArgsGet) !HetznerClient {
	mut args := args_

	// get session if specified, otherwise the default
	mut session := args.session or {
		mut session2 := play.session_new(
			interactive: true
		)!
		session2
	}

	mut c := configurator(args.instance, mut session)!

	if !(c.exists()!) {
		return error("Can't find hetzner configuration for instance:${args.instance}")
	}

	myconfig := c.get()!

	challenge := myconfig.user + ':' + myconfig.pass
	auth := base64.encode(challenge.bytes())

	mut h := HetznerClient{
		instance: args.instance
		user: myconfig.user
		pass: myconfig.pass
		base: myconfig.base
		auth: auth
	}

	sl := h.servers_list()!

	// println(sl)

	return h
}

@[params]
pub struct ClientArgsNew {
pub mut:
	instance string = 'default'
	login    string
	passwd   string
	base     string = 'https://robot-ws.your-server.de'
	session  ?&base.Session
}

// get a new hetzner client, will create if it doesn't exist or ask for new configuration
pub fn new(args_ ClientArgsNew) !HetznerClient {
	mut args := args_

	// get session if specified, otherwise the default
	mut session := args.session or {
		mut session2 := play.session_new(
			interactive: true
		)!
		session2
	}

	if session.interactive {
		mut ui := gui.new()!
		if args.login == '' {
			args.login = ui.ask_question(
				question: '\nPlease specify your login for your hetzner environment (instance:${args.instance}).'
			)!
		}
		if args.passwd == '' {
			args.passwd = ui.ask_question(
				question: '\nPlease specify your passwd for your hetzner environment (instance:${args.instance}).'
			)!
		}
	} else {
		if args.login == '' || args.passwd == '' {
			// check config already exists
			return error('non interactive session need to specifigy login and passwd ')
		}
	}

	mut c := configurator(args.instance, mut session)!

	myconfig := HetznerConfig{
		user: args.login
		pass: args.passwd
		base: args.base
	}

	c.set(myconfig)!

	return get(instance: args.instance, session: session)
}
