module main

import installers.caddy

fn do() ! {
	caddy.install()!
	caddy.configure_examples()!
	caddy.restart()!
}

fn main() {
	do() or { panic(err) }
}
