module main

// import os
import nedpals.vex.router
import nedpals.vex.server
import nedpals.vex.ctx
import despiegk.crystallib.publisher_config
import json

fn print_req_info(mut req ctx.Req, mut res ctx.Resp) {
	println('$req.method $req.path')
}

struct MyContext {
	config &publisher_config.ConfigRoot
	// now you can inject other stuff also
}

fn helloworld(req &ctx.Req, mut res ctx.Resp) {
	myconfig := (&MyContext(req.ctx)).config
	res.send('Hello World! $developer_config.publish.path.base', 200)
}

// Run server
pub fn webserver_run(config publisher_config.ConfigRoot) {
	mut app := router.new()

	mycontext := &MyContext{
		config: &config
	}
	app.inject(mycontext)

	app.use(print_req_info)

	app.route(.get, '/hello', helloworld)

	server.serve(app, 6789)
}
