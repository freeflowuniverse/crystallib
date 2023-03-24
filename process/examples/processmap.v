module main

import freeflowuniverse.crystallib.process

fn do() ? {
	mut pm := process.processmap_get()?
	println(pm)
}

fn main() {
	do() or { panic(err) }
}
