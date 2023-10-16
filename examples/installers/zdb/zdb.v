module main

import freeflowuniverse.crystallib.installers.zdb

fn do() ! {
	// shortcut to install the base
	zdb.install()!
}

fn main() {
	do() or { panic(err) }
}
