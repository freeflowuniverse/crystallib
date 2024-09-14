#!/usr/bin/env -S v -n -cg -w -enable-globals run

import veb
import os

import freeflowuniverse.crystallib.core.texttools

pub struct User {
pub mut:
	name string
	id   int
}

pub struct Context {
	veb.Context
pub mut:
	// In the context struct we store data that could be different
	// for each request. Like a User struct or a session id
	user       User
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

@['/hello/:user']
pub fn (app &App) hello_user(mut ctx Context, user string) veb.Result {
	d:=texttools.template_replace($tmpl("templates/index.html"))
	return ctx.text(d)
}



mut app := &App{
	secret_key: 'secret'
}

app.mount_static_folder_at('/root/code/github/freeflowuniverse/crystallib/examples/webserver/veb/static', '/static')!



veb.run[App, Context](mut app, 8090)
