module main

import freeflowuniverse.crystallib.installers.zinit

fn do() ! {
	zinit.build()!
	// zinit.install()!
	// zinit.restart()!
}

fn main() {
	do() or { panic(err) }
}
