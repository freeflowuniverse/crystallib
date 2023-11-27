module main

import freeflowuniverse.crystallib.builder

fn do1() ! {
	builder.bootstrapper()!
}

fn main() {
	do1() or { panic(err) }
}
