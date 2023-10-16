module main

import freeflowuniverse.crystallib.installers.vlang

fn do() ! {
	// shortcut to install the base

	vlang.get_install()!
}

fn main() {
	do() or { panic(err) }
}
