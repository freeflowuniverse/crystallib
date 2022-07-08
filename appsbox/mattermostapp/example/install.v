module main

import freeflowuniverse.crystallib.appsbox.mattermostapp

fn do() ? {
	mut app := mattermostapp.get(name: 'mm-main')
	app.start()?
}

fn main() {
	do() or { panic(err) }
}
