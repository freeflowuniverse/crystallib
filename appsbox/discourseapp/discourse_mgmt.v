module discourseapp

import os
import builder
import appsbox

[heap]
pub struct DiscourseApp {
pub mut:
	name			string
	appconfig		appsbox.AppConfig
}

pub struct DiscourseAppArgs {
	name				string = "default"
	port				int = 5432
	unixsocketpath		string = ""
	postgres_passwd	    string = "oursecret" //should be changed by user when init
}

pub fn get(args DiscourseAppArgs) appsbox.App {
	mut factory := appsbox.get()

	for item in factory.apps{
		if item.appconfig.tcpports == [args.port] && item.appconfig.name == args.name {
			return item
		}
	}

	println("[-] appconfig not found, creating a new one")

	mut i := appsbox.AppConfig {
		name: args.name
		tcpports: [args.port]
	}

	mut myapp := DiscourseApp {
		name: args.name,
		appconfig: i
	}

	factory.apps << myapp
	return myapp
}

pub fn (mut myapp DiscourseApp) start() ?{
	mut factory := appsbox.get()

	myapp.install(false)?

	mut n := builder.node_local()?

	// start gitea
	servername := "example.com"
	// docker run -it --name $name -e DISCOURSE_HOSTNAME=$servername $imagename
}

pub fn (mut myapp DiscourseApp) stop() ? {
	println("stop")
}

pub fn (mut myapp DiscourseApp) install(reset bool)?{
	mut factory := appsbox.get()

	mut n := builder.node_local()?

	myapp.appconfig.bins = ["discourse"]

	// check app is installed, if yes don't need to do anything
	// if reset || ! myapp.appconfig.exists() {
	if reset { // CHECK FOR DOCKER IMAGE
		myapp.build()?
	}
}

pub fn (mut myapp DiscourseApp) build() ? {
	mut factory := appsbox.get()

	mut n := builder.node_local()?

	tmpdir := "/tmp/discourse/"
	binpath := factory.bin_path
	buildpath := tmpdir + "source"
	imagename := "threefolddev/discourse_aio"

	mut cmd := $tmpl("discourse_build.sh")
	n.exec(cmd:cmd, reset:true, description:"install discourse; echo ok",stdout:true, tmpdir:tmpdir)?
}

pub fn (mut myapp DiscourseApp) check() ?bool {
	println("check")
	return false
}

pub fn (mut myapp DiscourseApp) client() ? {
	println("client")
}
