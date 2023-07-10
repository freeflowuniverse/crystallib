module discourseapp

import os
import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.appsbox

[heap]
pub struct DiscourseApp {
pub mut:
	name     string
	instance appsbox.AppInstance
}

pub struct DiscourseAppArgs {
	name            string = 'default'
	port            int    = 5432
	unixsocketpath  string = ''
	postgres_passwd string = 'oursecret' // should be changed by user when init
}

pub fn get(args DiscourseAppArgs) appsbox.App {
	mut factory := appsbox.get()

	for item in factory.apps {
		if item.instance.tcpports == [args.port] && item.instance.name == args.name {
			return item
		}
	}

	println('[-] instance not found, creating a new one')

	mut i := appsbox.AppInstance{
		name: args.name
		tcpports: [args.port]
	}

	mut myapp := DiscourseApp{
		name: args.name
		instance: i
	}

	factory.apps << myapp
	return myapp
}

pub fn (mut myapp DiscourseApp) start() ? {
	mut factory := appsbox.get()

	myapp.install(false)?

	mut n := builder.node_local()?

	// start gitea
	servername := 'example.com'
	// docker run -it --name $name -e DISCOURSE_HOSTNAME=$servername $imagename
}

pub fn (mut myapp DiscourseApp) stop() ? {
	println('stop')
}

pub fn (mut myapp DiscourseApp) install(reset bool) ? {
	mut factory := appsbox.get()

	mut n := builder.node_local()?

	myapp.instance.bins = ['discourse']

	// check app is installed, if yes don't need to do anything
	// if reset || ! myapp.instance.exists() {
	if reset { // CHECK FOR DOCKER IMAGE
		myapp.build()?
	}
}

pub fn (mut myapp DiscourseApp) build() ? {
	mut factory := appsbox.get()

	mut n := builder.node_local()?

	tmpdir := '/tmp/discourse/'
	binpath := factory.bin_path
	buildpath := tmpdir + 'source'
	imagename := 'threefolddev/discourse_aio'

	mut cmd := $tmpl('discourse_build.sh')
	n.exec(
		cmd: cmd
		reset: true
		description: 'install discourse; echo ok'
		stdout: true
		tmpdir: tmpdir
	)?
}

pub fn (mut myapp DiscourseApp) check() ?bool {
	println('check')
	return false
}

pub fn (mut myapp DiscourseApp) client() ? {
	println('client')
}
