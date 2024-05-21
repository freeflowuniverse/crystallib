module dagu

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.clients.httpconnection
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.playbook

pub struct DaguClient[T] {
	base.BaseConfig[T]
pub mut:
	connection &httpconnection.HTTPConnection
}

pub struct Config {
pub mut:
	url       string
	username  string
	password  string
	apisecret string @[secret]
}

@[params]
pub struct DaguClientArgs {
pub mut:
	instance string = 'default'
	config   ?Config
}

pub fn new(instance string, cfg Config) !DaguClient[Config]{
	mut con := httpconnection.HTTPConnection{}
	mut self:=DaguClient[Config]{type_name:"DaguClient", connection: &con}
	self.init(instance:instance,action:.new)!
	self.config_set(cfg)!
	return self
}

pub fn get(instance string) !DaguClient[Config]{
	mut con := httpconnection.HTTPConnection{}
	mut self:=DaguClient[Config]{type_name:"DaguClient", connection: &con}
	self.init(instance:instance,action:.get)!
	return self
}

pub fn delete(instance string) !{
	mut con := httpconnection.HTTPConnection{}
	mut self:=DaguClient[Config]{type_name:"DaguClient", connection: &con}
	self.init(instance:instance,action:.delete)!
}

pub fn heroplay(mut plbook playbook.PlayBook) ! {
	for mut action in plbook.find(filter: 'daguclient.define')! {
		mut p := action.params
		instance := p.get_default('instance', 'default')!
		mut cl := get(instance)!
		mut cfg := cl.config_get()!
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

	mut cfg := self.config_get()!

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
