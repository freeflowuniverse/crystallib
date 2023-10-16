module main

import freeflowuniverse.crystallib.installers.mdbook
import freeflowuniverse.crystallib.installers.caddy

fn install() ! {
	// shortcut to install the base

	mut caddy := caddy.get_install()!

	caddy.configure_webserver_default('/var/www', 'd.threefold.me i.threefold.me')!

	c := caddy.configuration_get()!
	println(c)

	// mdbook.get_install()!
}

fn reload() ! {
	// shortcut to install the base

	mut caddy := caddy.get()!

	caddy.restart()!
}

fn main() {
	install() or { panic(err) }
	// reload() or { panic(err) }
}
