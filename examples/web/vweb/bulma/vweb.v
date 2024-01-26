module main

import vweb
import db.sqlite
// import freeflowuniverse.crystallib.web.components
import os

const pubpath = os.dir(@FILE) + '/public'

// fn print_req_info(mut req ctx.Req, mut res ctx.Resp) {
// 	// println(req)
// 	println('${req.method} ${req.path}')
// }

// fn do_stuff(mut req ctx.Req, mut res ctx.Resp) {
// 	println('incoming request!')
// }

struct App {
	vweb.Context
	middlewares map[string][]vweb.Middleware
pub mut:
	user_id string
}

fn main() {
	db := sqlite.connect('/tmp/web.db') or { panic(err) }

	vweb.run_at(new_app(), vweb.RunParams{
		port: 8081
	}) or { panic(err) }
}

pub fn (mut app App) before_request() {
	app.user_id = app.get_cookie('id') or { '0' }
}

fn new_app() &App {
	mut app := &App{
		middlewares: {
			'/': [midleware_debug]
		}
	}
	// makes all static files available.
	app.mount_static_folder_at(os.resource_abs_path('.'), '/')
	return app
}

fn midleware_debug(mut ctx vweb.Context) bool {
	println(ctx.req)
	println(ctx.query)
	println(ctx.form)
	return true
}

struct Object {
	title       string
	description string
}


@['/']
pub fn (mut app App) page_home() vweb.Result {
	// all this constants can be accessed by src/templates/page/home.html file.
	title := 'This is our title'
	return $vweb.html()
}

