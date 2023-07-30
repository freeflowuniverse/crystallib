module main

import freeflowuniverse.crystallib.builder
import installers.caddy

fn do() ! {
	// do basic install on a node
	mut n := builder.node_local()!
	caddy.install_configure(node: mut n)!
}

fn main() {
	do() or { panic(err) }
}
