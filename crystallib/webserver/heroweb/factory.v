module heroweb

import veb
import os
import freeflowuniverse.crystallib.security.authentication {Authenticator}
import freeflowuniverse.crystallib.security.authorization {Authorizer}
import freeflowuniverse.crystallib.clients.mailclient

pub struct App {
	veb.StaticHandler
	veb.Middleware[Context]
mut:
	authenticator Authenticator
	authorizer Authorizer
pub:
	base_url string = 'http://localhost:8090'
	secret_key string = '1234'
}

pub fn (app &App) index(mut ctx Context) veb.Result {
	return ctx.text('Hello V! The secret key is "${app.secret_key}"')
}

//@['/hello/:user']
@['/wiki']
pub fn (app &App) hello_user(mut ctx Context, user string) veb.Result {
	doc := model_example()
	d := $tmpl('templates/index.html')
	return ctx.html(d)
}


@['/kanban']
pub fn (app &App) kanban(mut ctx Context) veb.Result {
	data := kanban_example()
	d := $tmpl('templates/kanban.html')
	return ctx.html(d)
}

pub struct AppConfig {
pub:
	authenticator Authenticator
	authorizer Authorizer
}

pub fn new(config AppConfig) !&App {
	mut app := &App{
		authenticator: config.authenticator
		authorizer: config.authorizer
	}

	app.mount_static_folder_at('${os.home_dir()}/code/github/freeflowuniverse/crystallib/crystallib/webserver/heroweb/static','/static')!
	return app
}


pub fn example() ! {
	mut app := &App{
		secret_key: 'secret'
	}

	// app.mount_static_folder_at('${os.home_dir()}/github/freeflowuniverse/crystallib/crystallib/webserver/heroweb/static','/static')!
	app.mount_static_folder_at('static', '/static')!

	//model_auth_example()!

	veb.run[App, Context](mut app, 8090)
}
