module main

import freeflowuniverse.crystallib.appsbox.redisapp

fn do() ? {
	mut app := redisapp.get(port: 7788)
	app.build()?
}

fn main() {
	do() or { panic(err) }
}
