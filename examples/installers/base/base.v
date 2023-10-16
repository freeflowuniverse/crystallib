module main

import freeflowuniverse.crystallib.installers.base

fn do() ! {
	// shortcut to install the base
	base.install()!
}

fn main() {
	do() or { panic(err) }
}
