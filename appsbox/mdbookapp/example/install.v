module main

import despiegk.crystallib.appsbox.mdbookapp

fn do() ? {
	mut app := mdbookapp.get()
	app.install(false)?
}

fn main() {
	do() or { panic(err) }
}
