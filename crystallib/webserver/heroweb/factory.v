module heroweb

import veb
import os
// import freeflowuniverse.crystallib.core.texttools

pub struct App {
	veb.StaticHandler
pub:
	secret_key string = '1234'
}

pub fn (app &App) index(mut ctx Context) veb.Result {
	return ctx.text('Hello V! The secret key is "${app.secret_key}"')
}

@['/hello/:user']
pub fn (app &App) hello_user(mut ctx Context, user string) veb.Result {
	doc := model_example()
	d := $tmpl('templates/index.html')
	return ctx.html(d)
}

@['/calendar']
pub fn (app &App) calendar(mut ctx Context) veb.Result {
	// data := calendar_example()
	d := $tmpl('templates/calendar.html')
	return ctx.html(d)
}

@['/kanban']
pub fn (app &App) kanban(mut ctx Context) veb.Result {
	data := kanban_example()
	d := $tmpl('templates/kanban.html')
	return ctx.html(d)
}

pub fn example() ! {
	mut app := &App{
		secret_key: 'secret'
	}

	// app.mount_static_folder_at('${os.home_dir()}/github/freeflowuniverse/crystallib/crystallib/webserver/heroweb/static','/static')!
	app.mount_static_folder_at('static', '/static')!

	veb.run[App, Context](mut app, 8090)
}
