module main

import freeflowuniverse.crystallib.builder

fn do() ! {
	mut builder := builder.new()
	mut node := builder.node_local()!
	// mut node2 := builder.node_local(reload:true)!

	println(node)
	// println(node2)
}

fn main() {
	do() or { panic(err) }
}
