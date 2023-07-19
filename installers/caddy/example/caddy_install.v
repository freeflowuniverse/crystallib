
module main
import freeflowuniverse.crystallib.builder
import crystallib.installers.caddy

fn do() ! {

	//do basic install on a node
	mut n:=builder.node_local()!
	caddy.install(mut n)!
	caddy.install_test(node:mut n)!

}

fn main() {

	do() or { panic(err) }
}
