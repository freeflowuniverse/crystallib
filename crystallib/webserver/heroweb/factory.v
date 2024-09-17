module heroweb

import veb
import os
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.clients.mailclient

pub struct App {
	veb.StaticHandler
	veb.Middleware[Context]
mut:
	db WebDB
pub:
	base_url string = 'http://localhost:8090'
	secret_key string = '1234'
}

pub fn (app &App) index(mut ctx Context) veb.Result {
	return ctx.text('Hello V! The secret key is "${app.secret_key}"')
}


// TODO: no longer needed
// pub struct AppConfig {
// pub:
// 	authenticator Authenticator
// 	authorizer Authorizer
// }


//the path is pointing to the instructions
pub fn new(path string) !&App {
	mut app := &App{
		db: WebDB{}
	}

	app.mount_static_folder_at('${os.home_dir()}/code/github/freeflowuniverse/crystallib/crystallib/webserver/heroweb/static','/static')!

	mut plbook := playbook.new(path: path)!

	//lets make sure the authentication is filled in
	app.db.play_auth(mut plbook)!
	//now lets add the infopointers
	app.db.play_infopointers(mut plbook)!

	//lets run the heroscripts
	for key, ip in app.db.infopointers{
		db.infopointer_run(key)!
	}
	

	console.print_stdout(plbook.str())


	return app
}


pub fn example() ! {
	mut app := &App{
		secret_key: 'secret'
	}

	//app.mount_static_folder_at('static', '/static')!
	app.mount_static_folder_at('${os.home_dir()}/code/github/freeflowuniverse/crystallib/crystallib/webserver/heroweb/static','/static')!

	//model_auth_example()!

	veb.run[App, Context](mut app, 8090)
}
