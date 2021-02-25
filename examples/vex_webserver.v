module main
// import os

import nedpals.vex.router
import nedpals.vex.server
import nedpals.vex.ctx

import myconfig
import json



fn print_req_info(mut req ctx.Req, mut res ctx.Resp) {
	println('${req.method} ${req.path}')
}

struct MyContext {
   config  &myconfig.ConfigRoot
   // now you can inject other stuff also
}


fn helloworld (req &ctx.Req, mut res ctx.Resp) {
		myconfig := (&MyContext(req.ctx)).config
		res.send('Hello World! ${myconfig.paths.base}', 200)
	}

// Run server
pub fn webserver_run() {	
    mut app := router.new()

	config := myconfig.get()
	mycontext := &MyContext{config: &config}
	app.inject(mycontext)

    app.use(print_req_info)

	app.route(.get, '/hello',helloworld )	

    server.serve(app, 6789)	

}

fn main(){
	webserver_run()
}

