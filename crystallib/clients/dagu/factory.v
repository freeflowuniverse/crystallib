module dagu

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.clients.httpconnection
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.playbook
import os

pub struct DaguClient[T] {
	base.BaseConfig[T]
pub mut:
	connection &httpconnection.HTTPConnection
}

pub struct DaguClientConfig {
pub mut:
	url       string
	username  string
	password  string
	apisecret string
}

@[params]
pub struct DaguClientArgs {
pub mut:
	instance string = 'default'
	config   ?DaguClientConfig
}

pub fn get(args DaguClientArgs) !DaguClient[DaguClientConfig] {
	con := httpconnection.HTTPConnection{}
	mut client := DaguClient[DaguClientConfig]{
		connection: &con
	}
	client.init(instance: args.instance)!

	if args.config != none {
		myconfig := args.config or { panic('bug') }
		client.config_set(myconfig)!
	}

	return client
}

pub fn heroplay(mut plbook playbook.PlayBook) ! {
	for mut action in plbook.find(filter: 'daguclient.define')! {
		mut p := action.params
		instance := p.get_default('instance', 'default')!
		mut cl := get(instance: instance)!
		mut cfg := cl.config()!
		cfg.url = p.get('url')!
		cfg.username = p.get('username')!
		cfg.password = p.get('password')!
		cl.config_save()!
	}
}

pub fn (mut self DaguClient[DaguClientConfig]) config_interactive() ! {
	mut myui := ui.new()!
	console.clear()
	println('\n## Configure Dagu Client')
	println('========================\n\n')

	mut cfg := self.config()!

	self.instance = myui.ask_question(
		question: 'name for Dagu client'
		default: self.instance
	)!

	cfg.url = myui.ask_question(
		question: 'dagu server url e.g. http://localhost:8080'
		minlen: 5
		default: cfg.url
	)!

	cfg.username = myui.ask_question(
		question: 'dagu server username'
		minlen: 2
		default: cfg.username
	)!

	cfg.password = myui.ask_question(
		question: 'dagu server password'
		default: cfg.password
		minlen: 6
	)!

	cfg.apisecret = myui.ask_question(
		question: 'dagu server api secret'
		default: cfg.password
		minlen: 6
	)!

	self.config_save()!
}
