#!/usr/bin/env -S v -w -enable-globals run
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.base

//THIS EXAMPLE WILL SHOW HOW TO FILL IN A TEMPLATE

pub struct MyClient[T] {
	base.BaseConfig[T]
}

pub struct MyConfig {
pub mut:
	//the config items which are important to remember
	keyname    string
	keyid      string
	appkey     string @[secret]
}

@[params]
pub struct MyClientArgs {
pub mut:
	instance string
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

//mut cl:=get(instance:"test",config:MyConfig{keyname:"anotherone",appkey:"eeee"})!

mut cl2:=get(instance:"test")!

mut myconfig:=cl2.config()!

//it should show how the fields are normal, but at back there was encryption/decryption of the field marked secret
println(myconfig)

// config_content:=$templ("aconfigfile.txt")

// myconfigfile:=pathlib.get_file(path:"/tmp/myconfigfile.txt",create:false)!
// myconfigfile.write(config_content)!