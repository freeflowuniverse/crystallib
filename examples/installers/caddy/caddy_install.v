module main

import freeflowuniverse.crystallib.installers.caddy
import freeflowuniverse.crystallib.installers.fungistor
import freeflowuniverse.crystallib.installers.zdb

fn do() ! {
	fungistor.install()!
	zdb.install()!
	caddy.install()!
	caddy.configure_examples()!
	caddy.restart()!
}

fn main() {
	do() or { panic(err) }
}
