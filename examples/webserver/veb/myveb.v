module main

import veb
import os
// import freeflowuniverse.crystallib.core.texttools


pub struct Context {
	veb.Context
pub mut:
	// In the context struct we store data that could be different
	// for each request. Like a User struct or a session id
	session_id string
}



pub struct App {
	veb.StaticHandler
pub:
	secret_key string = '1234'
}

pub fn (app &App) index(mut ctx Context) veb.Result {
	return ctx.text('Hello V! The secret key is "${app.secret_key}"')
}


pub fn main()  {
	mut app := &App{
		secret_key: 'secret'
	}

	// app.mount_static_folder_at('${os.home_dir()}/github/freeflowuniverse/crystallib/crystallib/webserver/heroweb/static','/static')!
	app.mount_static_folder_at('static', '/static')!

	//model_auth_example()!

	veb.run[App, Context](mut app, 8090)
}
