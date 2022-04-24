module main

import appsbox.discourseapp

fn do() ? {
	mut app := discourseapp.get(name: "d-main")
	app.build()?
}


fn main() {
	do() or {panic(err)}
}
