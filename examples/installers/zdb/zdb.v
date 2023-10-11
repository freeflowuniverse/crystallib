module main

import installers.zdb

fn do() ! {
	// shortcut to install the base
	mut i := zdb.install()!
}

fn main() {
	do() or { panic(err) }
}
