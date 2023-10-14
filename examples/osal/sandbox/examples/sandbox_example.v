module main

// import freeflowuniverse.crystallib.tools.tmux
import freeflowuniverse.crystallib.installers.caddy
import freeflowuniverse.crystallib.osal.sandbox
import os

// const configpath = os.dir(@FILE) + '/config'

fn do() ! {
	// kill the full tmux session, we will create new one
	// mut t := tmux.new()!

	// t.session_delete("main")! //kill the full tmux, is not done gracefully

	// t.window_new(name: 'mc', cmd: 'mc', reset: true)!	 //launch a window with mc

	// caddy.install(reset:true)! //will get the binary and put in /usr/local/bin
	// caddy.configuration_set(path:"${configpath}/Caddyfile",restart:true)!

	sandbox.install()! // will also do an upgrade of the OS
	mut f := sandbox.new()!
	// f.debootstrap()!
	mut c := f.container_new()!
	c.debootstrap()!
	c.start()!
}

fn main() {
	do() or { panic(err) }
}
