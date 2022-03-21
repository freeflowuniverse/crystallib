module giteapp

import os
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.appsbox

[heap]
pub struct GiteaApp {
pub mut:
	name			string
	instance		appsbox.AppInstance
}

pub struct GiteaAppArgs {
	name				string = "default"
	port				int = 5432
	unixsocketpath		string = ""
	postgres_passwd	    string = "oursecret" //should be changed by user when init
}

pub fn get(args GiteaAppArgs) appsbox.App {
	mut factory := appsbox.get()

	for item in factory.apps{
		if item.instance.tcpports == [args.port] && item.instance.name == args.name {
			return item
		}
	}

	println("[-] instance not found, creating a new one")

	mut i := appsbox.AppInstance {
		name: args.name
		tcpports: [args.port]
	}

	mut myapp := GiteaApp {
		name: args.name,
		instance: i
	}

	factory.apps << myapp
	return myapp
}

pub fn (mut myapp GiteaApp) start() ?{
	mut factory := appsbox.get()

	myapp.install(false)?

	mut n := builder.node_local()?

	// start gitea

	mut tcpport := myapp.instance.tcpports[0]
	bin_path := factory.bin_path

	//set a start command for postgresql
	cmd := "${bin_path}/gitea"
	n.exec(cmd:cmd, reset:true, description:"start postgres",stdout:true)?

	/*
	alive := myapp.check()?
	if ! alive{
		return error("Could not start postgres.")
	}
	*/
}

pub fn (mut myapp GiteaApp) stop() ? {
	println("stop")
}

pub fn (mut myapp GiteaApp) install(reset bool)?{
	mut factory := appsbox.get()

	mut n := builder.node_local()?

	myapp.instance.bins = ["gitea"]

	// check app is installed, if yes don't need to do anything
	if reset || ! myapp.instance.exists() {
		myapp.build()?
	}
}

pub fn (mut myapp GiteaApp) build() ? {
	mut factory := appsbox.get()

	mut n := builder.node_local()?

	tmpdir := "/tmp/gitea/"
	binpath := factory.bin_path
	gover := "1.15"

	mut cmd := $tmpl("gitea_build.sh")
	n.exec(cmd:cmd, reset:true, description:"install gitea; echo ok",stdout:true, tmpdir:tmpdir)?
}

pub fn (mut myapp GiteaApp) check() ?bool {
	println("check")
	return false
}

pub fn (mut myapp GiteaApp) client() ? {
	println("client")
}
