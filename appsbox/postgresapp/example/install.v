

module main

import despiegk.crystallib.appsbox.postgresapp


fn do()?{
	mut app := postgresapp.get()
	app.start()?
	app2.stop()?


}

fn main() {

	do() or {panic(err)}

}
