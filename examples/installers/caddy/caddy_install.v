module main

import freeflowuniverse.crystallib.installers.caddy
import freeflowuniverse.crystallib.installers.fungistor
import freeflowuniverse.crystallib.installers.zdb
import freeflowuniverse.crystallib.installers.s3
import freeflowuniverse.crystallib.installers.rclone
import freeflowuniverse.crystallib.installers.restic


fn do() ! {
	rclone.install()!
	restic.install()!
	// fungistor.install()!
	// zdb.install()!
	// s3.build()!
	// caddy.install()!
	// caddy.configure_examples()!
	// caddy.restart()!
}

fn main() {
	do() or { panic(err) }
}
