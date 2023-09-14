module main

import freeflowuniverse.crystallib.builder
import installers.golang

fn do() ! {
	// do basic install on a node
	mut n := builder.node_local()!
	golang.install(node: mut n)!
}

fn main() {
	do() or { panic(err) }
}
