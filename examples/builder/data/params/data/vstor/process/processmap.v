module main

import freeflowuniverse.crystallib.osal

fn do() ? {
	mut pm := process.processmap_get()?
	println(pm)
}

fn main() {
	do() or { panic(err) }
}
