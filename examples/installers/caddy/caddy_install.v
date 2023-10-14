module main

import freeflowuniverse.crystallib.installers.caddy

fn do() ! {
	caddy.install()!
	caddy.configure_examples()!
	caddy.restart()!
}

fn main() {
	do() or { panic(err) }
}
