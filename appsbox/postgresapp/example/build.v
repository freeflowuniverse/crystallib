module main

import freeflowuniverse.crystallib.appsbox.postgresapp

fn do() ? {
	mut app := postgresapp.get(port: 1144)
	app.build()?
}

fn main() {
	do() or { panic(err) }
}
