module main

import appsbox.giteapp

fn do() ? {
	mut app := giteapp.get(name: 'maingit')
	app.start()?
}

fn main() {
	do() or { panic(err) }
}
