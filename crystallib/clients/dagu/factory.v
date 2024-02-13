module dagu

import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.clients.httpconnection
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console
import os


pub struct DaguClient[T] {
	play.Base[T]
pub mut:
	connection &httpconnection.HTTPConnection
}

pub struct Config {
	play.ConfigBase
pub mut:
	configtype string = 'daguclient' // needs to be defined	
	url    string 
	username      string
	password     string
}

pub fn get(args play.PlayArgs) !DaguClient[Config] {
	con := httpconnection.HTTPConnection{}
	mut client := DaguClient[Config]{
		connection: &con
	}
	client.init(args)!
	return client
}

pub fn heroplay(args play.PLayBookAddArgs) ! {
	// make session for configuring from heroscript
	mut session := play.session_new(session_name: 'config')!
	session.playbook_add(path: args.path, text: args.text, git_url: args.git_url)!
	for mut action in session.plbook.find(filter: 'daguclient.define')! {
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

pub fn (mut self DaguClient[Config]) config_interactive() ! {
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

	self.config_save()!
}


