module main3

import installers.imagemagick

fn do() ? {
	// shortcut to install the base
	mut i := imagemagick.install()?
	println(i)
}

fn main3() {
	do() or { panic(err) }
}
