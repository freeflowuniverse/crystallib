

module main

import appsbox.penapp


fn do()?{

	mut app := penapp.get()
	app.install(false)?	

}

fn main() {

	do() or {panic(err)}

}
