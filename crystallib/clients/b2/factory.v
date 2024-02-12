module b2

import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.lang.python

pub struct B2Client[T] {
	play.Base[T]
pub mut:
	py python.PythonEnv
}

pub struct Config {
	play.ConfigBase
pub mut:
	configtype string = 'b2client' // needs to be defined	
	keyname    string
	keyid      string
	appkey     string
	bucketname string // can be empty is the default
}

// get instance of our client params: .
// instance string = "default".
// playargs ?PlayArgs (defines how to get session and/or context)
//
pub fn get(args play.PlayArgs) !B2Client[Config] {
	mut py := python.new(name: 'default')! // a python env with name test
	mut client := B2Client[Config]{
		py: py
	}
	client.init(args)!
	return client
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
pub fn heroplay(args play.PLayBookAddArgs) ! {
	// make session for configuring from heroscript
	mut session := play.session_new(session_name: 'config')!
	session.playbook_add(path: args.path, text: args.text, git_url: args.git_url)!
	for mut action in session.plbook.find(filter: 'b2client.define')! {
		mut p := action.params
		instance := p.get_default('instance', 'default')!
		mut cl := get(instance: instance)!
		mut cfg := cl.config()!
		cfg.description = p.get('description')!
		cfg.keyid = p.get('keyid')!
		cfg.keyname = p.get('keyname')!
		cfg.appkey = p.get('appkey')!
		cl.config_save()!
	}
}

pub fn (mut self B2Client[Config]) config_interactive() ! {
	mut myui := ui.new()!
	console.clear()
	println('\n## Configure B2 Client')
	println('========================\n\n')

	mut cfg := self.config()!

	self.instance = myui.ask_question(
		question: 'name for B2 (backblaze) client'
		default: self.instance
	)!

	cfg.description = myui.ask_question(
		question: 'description'
		minlen: 0
		default: cfg.description
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
