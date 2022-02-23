

module main

import despiegk.crystallib.appsbox.postgresapp


fn do()?{
	mut app := postgresapp.get(port:7777)
	app.build()?
}

fn main() {
	do() or {panic(err)}

}
