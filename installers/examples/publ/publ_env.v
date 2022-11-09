module main

import freeflowuniverse.crystallib.builder
import installers.mdbook
import installers.caddy

fn install() ! {
	// shortcut to install the base
	mut builder := builder.new()
	mut node := builder.node_new(ipaddr: '185.69.166.150', name: 'kds')!
	mut caddy := caddy.get_install(mut node)!

	caddy.configure_webserver_default('/var/www', 'd.threefold.me i.threefold.me')!

	c := caddy.configuration_get()!
	println(c)

	// mdbook.get_install(mut node)!
}

fn reload() ! {
	// shortcut to install the base
	mut builder := builder.new()
	mut node := builder.node_new(ipaddr: '185.69.166.150', name: 'kds')!
	mut caddy := caddy.get(mut node)!

	caddy.restart()!
}

fn main() {
	install() or { panic(err) }
	// reload() or { panic(err) }
}
