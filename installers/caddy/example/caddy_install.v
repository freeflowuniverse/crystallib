module main


import installers.caddy

fn do() ! {
	caddy.install()!
}

fn main() {
	do() or { panic(err) }
}
