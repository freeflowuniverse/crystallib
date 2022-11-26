module main

import freeflowuniverse.crystallib.builder

fn do() ! {
	mut builder := builder.new()
	mut node := builder.node_local()!

	mut engine := engine_local([]) or { panic(err) }

	engine.reset_all()!

	// TODO: HOW CAN WE CHECK THE LIST OF IMAGES IS EMPTY?
	// NEXT IS NOT WORKING
	mut il := engine.images_list() or { panic(err) }
	mut cl := engine.containers_get() or { panic(err) }


	println(node)
}

fn main() {
	do() or { panic(err) }
}
