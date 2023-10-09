module main

import installers.base

fn do() ! {
	// shortcut to install the base
	mut i := base.install()!
	println(i)
}

fn main() {
	do() or { panic(err) }
}
