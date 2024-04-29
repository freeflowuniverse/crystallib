#!/usr/bin/env -S v -w -enable-globals run

import freeflowuniverse.crystallib.core.base

//THIS EXAMPLE USES A SESSION TO USE THAT CONTEXT

pub struct MyClient[T] {
	base.BaseConfig[T]
}

@[params]
pub struct MyConfig {
pub mut:
	//the config items which are important to remember
	keyname    string
	keyid      string
	appkey     string @[secret]
}

pub fn new(instance string, cfg MyConfig) !MyClient[MyConfig]{
	mut self:=MyClient[MyConfig]{}
	self.init(instance:instance,action:.new)!
	self.config_set(cfg)!
	return self
}

pub fn get(instance string) !MyClient[MyConfig]{
	mut self:=MyClient[MyConfig]{}
	self.init(instance:instance,action:.get)!
	return self
}

pub fn delete(instance string) !{
	mut self:=MyClient[MyConfig]{}
	self.init(instance:instance,action:.delete)!
}

//ABOVE IS THE STD STUFF

mut cl:=new("testinstance",keyname:"somekey",appkey:"will be secret")!

//we will now attach the session to it

mut mysession:=base.session_new(
    coderoot:'/tmp/code'
    interactive:true
	context_name:"test"  //the configuration will be in that dir too
)!

cl.session_set(session:mysession)!