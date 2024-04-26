#!/usr/bin/env -S v -w -enable-globals run


import freeflowuniverse.crystallib.core.base

//THIS EXAMPLE IS A VERY EASY ONE WHERE WE SET THE CONFIG AFTERWARDS


pub struct MyClient[T] {
	base.BaseConfig[T]
}

pub struct MyConfig {
pub mut:
	//the config items which are important to remember
	keyname    string
	keyid      string
	appkey     string
}

@[params]
pub struct MyClientArgs {
pub mut:
	instance string = "default"
}

pub fn get(args MyClientArgs) !MyClient[MyConfig]{
	mut client:=MyClient[MyConfig]{}
	client.init(instance:args.instance)!
	return client
}

mut cl:=get()!

mut myconfig:=cl.config()!

//first time this config will be empty, next time will already be populated
println(myconfig)

myconfig.keyname="akey"
myconfig.appkey="1234"

cl.config_save()!

println(cl.config_)