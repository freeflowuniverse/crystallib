

module main

import appsbox.redisapp


fn do()?{
	mut app := redisapp.get(port:7777)
	app.start()?
	mut app2 := redisapp.get(port:7778)
	app2.start()?
	app.stop()?
	app2.stop()?


}

fn main() {

	do() or {panic(err)}

}
