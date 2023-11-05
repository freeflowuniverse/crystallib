module main

import freeflowuniverse.crystallib.installers.golang

fn do() ! {
	// do basic install on a node
	golang.install(node: mut n)!
}

fn main() {
	do() or { panic(err) }
}
