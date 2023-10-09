module main

import freeflowuniverse.crystallib.docker

fn do() ! {
	mut engine := docker.new()!

	engine.reset_all()!

	println(engine)

	// engine.containers[0].shell()!
}

fn main() {
	do() or { panic(err) }
}
