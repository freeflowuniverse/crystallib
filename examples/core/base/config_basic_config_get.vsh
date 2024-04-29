#!/usr/bin/env -S v -w -enable-globals run


import freeflowuniverse.crystallib.core.base

//THIS EXAMPLE SHOWS HOW TO DO THE CONFIGURATION IN THE FACTORY

pub struct MyClient[T] {
	base.BaseConfig[T]
}

pub struct MyConfig {
pub mut:
	//the config items which are important to remember
	keyname    string
	keyid      string
	appkey     string @[secret ] //this tells the config manager to encrypt this field
}

@[params]
pub struct MyClientArgs {
pub mut:
	instance string = "default"
	config ?MyConfig
}

pub fn get(args MyClientArgs) !MyClient[MyConfig]{
	mut client:=MyClient[MyConfig]{}
	client.init(instance:args.instance)!

	if args.config!=none{
		myconfig := args.config or {panic("bug")}
		client.config_set(myconfig)!
	}

	return client
}

mut cl:=get(instance:"test",config:MyConfig{keyname:"anotherone",appkey:"eeee"})!

mut myconfig:=cl.config()!
println(myconfig)

