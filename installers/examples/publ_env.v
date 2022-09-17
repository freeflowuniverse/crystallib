module main
import freeflowuniverse.crystallib.builder
import installers.mdbook

fn do() ? {
	// shortcut to install the base
	mut builder := builder.new()
	mut node := builder.node_new(ipaddr:"185.69.166.151",name:"kds")?
	mut i := mdbook.get(mut node)?
	// i.install()
	println(i)
}

fn main() {
	do() or { panic(err) }
}
