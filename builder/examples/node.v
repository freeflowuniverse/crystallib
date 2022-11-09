module main

import freeflowuniverse.crystallib.builder

fn do() ! {
	mut builder := builder.new()
	mut node := builder.node_local()!

	println(node)
}

fn main() {
	do() or { panic(err) }
}
