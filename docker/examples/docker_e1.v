module main

import docker

fn do() ! {
	mut engine := docker.new()!

	// engine.reset_all()!

	println(engine)
}

fn main() {
	do() or { panic(err) }
}
