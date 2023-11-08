module main

import freeflowuniverse.crystallib.installers.caddy
import freeflowuniverse.crystallib.installers.fungistor
import freeflowuniverse.crystallib.installers.zdb
import freeflowuniverse.crystallib.installers.s3

fn do() ! {
	fungistor.install()!
	zdb.install()!
	s3.build()!
	// s3.install()!
	// caddy.install()!
	// caddy.configure_examples()!
	// caddy.restart()!
}

fn main() {
	do() or { panic(err) }
}
