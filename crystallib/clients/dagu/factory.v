module dagu

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.ui as gui
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.clients.httpconnection

// import freeflowuniverse.crystallib.ui.console

pub struct DaguClient[T] {
	base.BaseConfig[T]
pub mut:
	connection &httpconnection.HTTPConnection
}

@[params]
pub struct Config {
pub mut:
	url       string
	username  string
	password  string
	apisecret string @[secret]
}

pub fn get(instance string, cfg Config) !DaguClient[Config] {
	mut self := DaguClient[Config]{
		connection: &httpconnection.HTTPConnection{}
	}

	if cfg.username.len > 0 {
		// first the type of the instance, then name of instance, then action
		self.init('daguclient', instance, .set, cfg)!
	} else {
		self.init('daguclient', instance, .get)!
	}

	mut conn := httpconnection.new(
		name: 'dagu'
		url: 'https://api.openai.com/v1/'
	)!

	// conn.default_header.add(.authorization, 'Bearer ${self.config()!.apisecret}')
	// req.add_custom_header('x-disable-pagination', 'True') !

	self.connection = conn
	return self
}

pub fn configure(instance_ string) ! {
	mut cfg := Config{}
	mut myui := gui.new()!

	mut instance := instance_
	if instance == '' {
		instance = myui.ask_question(
			question: 'name for Dagu client'
			default: instance
		)!
	}

	console.clear()
	console.print_debug('\n## Configure Dagu Client')
	console.print_debug('========================\n\n')

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

	get(instance, cfg)!
}
