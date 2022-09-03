module main

import appsbox.mdbookapp

fn do() ? {
	mut app := mdbookapp.get()
	app.install(false)?
}

fn main() {
	do() or { panic(err) }
}
