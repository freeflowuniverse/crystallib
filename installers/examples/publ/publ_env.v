module main2

import freeflowuniverse.crystallib.builder
import installers.mdbook
import installers.caddy

fn do() ? {
	// shortcut to install the base
	mut builder := builder.new()
	mut node := builder.node_new(ipaddr: '185.69.166.150', name: 'kds')?
	caddy.get_install(mut node)?
	// mdbook.get_install(mut node)?
}

fn main2() {
	do() or { panic(err) }
}
