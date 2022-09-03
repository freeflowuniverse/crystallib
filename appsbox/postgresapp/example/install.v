module main

import appsbox.postgresapp

fn do() ? {
	mut app := postgresapp.get(name: 'inst1')
	app.start()?
	app.stop()?
}

fn main() {
	do() or { panic(err) }
}
