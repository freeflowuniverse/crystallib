module main2

import osal.docker

fn do() ! {
	mut engine := docker.new()!

	// engine.reset_all()!

	dockerhub_datapath := '/Volumes/FAST/DOCKERHUB'

	engine.registry_add(datapath: dockerhub_datapath, ssl: true)!

	println(engine)
}

fn main() {
	do() or { panic(err) }
}
