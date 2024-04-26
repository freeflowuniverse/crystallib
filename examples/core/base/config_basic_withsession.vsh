#!/usr/bin/env -S v -w -enable-globals run


import freeflowuniverse.crystallib.core.base

//THIS EXAMPLE USES A SESSION TO USE THAT CONTEXT

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
	session &base.Session
}

pub fn get(args MyClientArgs) !MyClient[MyConfig]{
	mut client:=MyClient[MyConfig]{}
	client.init(instance:args.instance,session:args.session)!
	return client
}

mut mysession:=base.session_new(
    coderoot:'/tmp/code'
    interactive:true
	context_name:"test"  //the configuration will be in that dir too
)!

mut cl:=get(session:mysession)!

mut myconfig:=cl.config()!

//first time this config will be empty, next time will already be populated
println(myconfig)

myconfig.keyname="akey1"
myconfig.appkey="1234"

cl.config_save()!

println(cl.config_)