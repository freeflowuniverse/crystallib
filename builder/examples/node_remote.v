module main

import freeflowuniverse.crystallib.builder
import freeflowuniverse.crystallib.installers.rust
import freeflowuniverse.crystallib.installers.mdbook
import freeflowuniverse.crystallib.installers.vlang
import freeflowuniverse.crystallib.installers.caddy

fn do() ? {
	mut builder := builder.new()

	mut node := builder.node_new(name:"test", ipaddr:"185.206.122.151", debug:true)?
	
	rust.get_install(mut node) or {panic("error: $err")}
	mdbook.get_install(mut node) or {panic("error: $err")}
	vlang.get_install(mut node) or {panic("error: $err")}
	caddy.get_install(mut node) or {panic("error: $err")}
	
}

fn main() {
	do() or { panic(err) }
}
