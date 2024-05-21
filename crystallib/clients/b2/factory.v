module b2

import freeflowuniverse.crystallib.core.base
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.lang.python

pub struct B2Client[T] {
	base.BaseConfig[T]
pub mut:
	py python.PythonEnv
}

pub struct Config {
pub mut:
	configtype string = 'b2client' // needs to be defined	
	keyname    string
	keyid      string
	appkey     string @[secret]
	bucketname string // can be empty is the default
}

pub fn new(instance string, cfg Config) !B2Client[Config] {
	mut py := python.new(name: 'default')! // a python env with name default
	mut self := B2Client[Config]{
		py: py
	}	
	self.init(instance: instance, action: .new)!
	self.config_set(cfg)!
	return self
}

// get instance of our client params
pub fn get(instance string) !B2Client[Config] {
	mut py := python.new(name: 'default')! // a python env with name default
	mut self := B2Client[Config]{
		type_name: 'b2client'
		py: py
	}
	self.init(instance: instance, action: .get)!
	return self
}

pub fn delete(instance string) ! {
	mut self := B2Client[Config]{
		type_name: 'b2client'
	}
	self.init(instance: instance, action: .delete)!
}

// run heroscript starting from path, text or giturl
//```
// !!b2client.define
//     name:'tf_write_1'
//     description:'ThreeFold Read Write Repo 1
//     keyid:'003e2a7be6357fb0000000001'
//     keyname:'tfrw'
//     appkey:'K003UsdrYOZou2ulBHA8p4KLa/dL2n4'
//
//
// path    string
// text    string
// git_url     string
//```	
pub fn heroplay(mut plbook playbook.PlayBook) ! {
	// make session for configuring from heroscript
	for mut action in plbook.find(filter: 'b2client.define')! {
		mut p := action.params
		instance := p.get_default('instance', 'default')!
		mut cl := get(instance)!
		mut cfg := cl.config_get()!
		cfg.keyid = p.get('keyid')!
		cfg.keyname = p.get('keyname')!
		cfg.appkey = p.get('appkey')!
		cfg.bucketname = p.get('bucketname')!
		cl.config_save()!
	}
}

pub fn (mut self B2Client[Config]) config_interactive() ! {
	mut myui := ui.new()!
	console.clear()
	println('\n## Configure B2 Client')
	println('========================\n\n')

	mut cfg := self.config_get()!

	self.instance = myui.ask_question(
		question: 'name for B2 (backblaze) client'
		default: self.instance
	)!

	cfg.keyid = myui.ask_question(
		question: 'keyid e.g. 003e2a7be6357fb0000000001'
		minlen: 5
		default: cfg.keyid
	)!

	cfg.appkey = myui.ask_question(
		question: 'appkey e.g. K008UsdrYOAou2ulBHA8p4KBe/dL2n4'
		minlen: 5
		default: cfg.appkey
	)!

	buckets := self.list_buckets()!
	bucket_names := buckets.map(it.name)

	cfg.bucketname = myui.ask_dropdown(
		question: 'choose default bucket name'
		items: bucket_names
	)!

	self.config_save()!
}
