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
	// says cargo not found, but when ssh into vm cargo command is found.
	// also added cargo path to .bash_profile and ran source .cargo/env
	mdbook.get_install(mut node) or {panic("error: $err")}
	
}

fn main() {
	do() or { panic(err) }
}
