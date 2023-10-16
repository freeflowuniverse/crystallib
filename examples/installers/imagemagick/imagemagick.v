module main

import freeflowuniverse.crystallib.installers.imagemagick

fn do() ! {
	// shortcut to install the base
	mut i := imagemagick.install()!
	println(i)
}

fn main() {
	do() or { panic(err) }
}
