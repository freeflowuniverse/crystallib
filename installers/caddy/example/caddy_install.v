module main


import installers.caddy

fn do() ! {
	// do basic install on a node

	caddy.install_configure(node: mut n)!
}

fn main() {
	do() or { panic(err) }
}
