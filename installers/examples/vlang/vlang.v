module main

import freeflowuniverse.crystallib.builder
import installers.vlang

fn do() ? {
	// shortcut to install the base
	mut builder := builder.new()
	mut node := builder.node_new(ipaddr: '185.69.166.150', name: 'kds')?
	vlang.get_install(mut node)?
}

fn main() {
	do() or { panic(err) }
}
