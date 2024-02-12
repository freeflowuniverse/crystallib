# Config

We try to make a std way how to do configuration, this is using the [kvs](kvs.md) underneith.

## How to use

A good example to look at is [crystallib/clients/b2](crystallib/clients/b2)

```golang
module b2
import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.lang.python

//a generic which inherits from base
pub struct B2Client[T] {
	play.Base[T]
pub mut:
    //this is the custom part of the client
	py  python.PythonEnv
}

//the configuration object as used in the client

@[params]
pub struct Config {
	play.ConfigBase
	configtype string = 'b2client' //needs to be defined
pub mut:
    //the custom config as relevant for this client (app)
	keyid   string
	keyname string
	appkey string
}

// THE MAIN FACTORY:
// get instance of our client params: .
// instance string = "default".
// playargs ?PlayArgs (defines how to get session and/or context)
pub fn get(args play.PlayArgs) !B2Client[Config] {
	mut py := python.new(name: 'default')! // a python env with name test
	mut client := B2Client[Config] {		
		instance: args.instance			
		py:py
	}
	client.init(args)!
	return client
}


//run heroscript starting from path, text or giturl
//```
// !!b2.define
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
pub fn heroplay(args play.PLayBookAddArgs) !{
	//make session for configuring from heroscript
	mut session:=play.session_new(session_name:"config")!
	session.playbook_add(path:args.path,text:args.text,git_url:args.git_url)!
	for mut action in session.plbook.find(filter: 'b2.define')! {
		mut p := action.params
		instance := p.get_default('instance', 'default')!
		mut cl:=get(instance:instance)!
		mut cfg:=cl.config()!
		cfg.description = p.get('description')!
		cfg.keyid = p.get('keyid')!
        ...
		cl.config_save()!
	}
}


pub fn (mut self B2Client[Config]) config_interactive() ! {
	mut myui := ui.new()!
	console.clear()
	println('\n## Configure B2 Client')
	println('========================\n\n')

	mut cfg:=self.config()!

	self.instance = myui.ask_question(
		question: 'name for B2 (backblaze) client'
		default: self.instance
	)!
    ...
	self.config_save()!

}

```

## utilization example


```golang
#!/usr/bin/env -S v -w -enable-globals run
import freeflowuniverse.crystallib.clients.b2

mut cl:=b2.get(instance:"test")!

//will delete the config
cl.config_delete()!

mut cfg:=cl.config()!
if cfg.appkey==""{
	// will ask questions if not filled in yet
	cl.config_interactive()!
}
println(cfg)

//will now change programatically
cfg.description="something else"
//will now save the config
cl.config_save()!

//we will now see how the description has been overwritten
println(cfg)

```


## Configurator is an object which allows the mgmt of the config

T is the generic which represents the config class

```golang

import freeflowuniverse.crystallib.clients.b2

mut cl:=b2.get(instance:"test")! //default client

//get the configurator which allows to work with more instances
mut configurator:=cl.configurator()!

fn configurator.exists() !bool

//remove the config instance
fn configurator.delete() ! 

//list all the items
fn configurator.list() ![]string 

struct PrintArgs {
	name string
}
fn configurator.configprint(args PrintArgs) !

```