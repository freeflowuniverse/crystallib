#!/usr/bin/env -S v -w -enable-globals run


import freeflowuniverse.crystallib.core.base


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
	mut self:=MyClient[MyConfig]{type_name:"myclient"}
	self.init(instance:instance,action:.new)!
	self.config_set(cfg)!
	return self
}

pub fn get(instance string) !MyClient[MyConfig]{
	mut self:=MyClient[MyConfig]{type_name:"myclient"}
	self.init(instance:instance,action:.get)!
	return self
}

pub fn delete(instance string) !{
	mut self:=MyClient[MyConfig]{type_name:"myclient"}
	self.init(instance:instance,action:.delete)!
}

//EXAMPLE USAGE

mut cl:=new("testinstance",keyname:"somekey",appkey:"will be secret")!
println(cl.config_get()!)

//now get the client, will give error if it doesn't exist
mut cl2:=get("testinstance")!
println(cl2.config_get()!)

delete("testinstance")!


