module main

import vweb
import freeflowuniverse.spiderlib.auth.jwt
import freeflowuniverse.spiderlib.auth.session
import net.http
import os
import log

const port = 8080

const host = 'http://localhost:${port}'

struct App {
	vweb.Context
	vweb.Controller
	logger         &log.Logger    @[vweb_global]
	session_client session.Client @[vweb_global]
}

pub fn (mut app App) get_username() bool {
	mut access_token_str := app.get_cookie('access_token') or { return true }
	access_token := jwt.SignedJWT(access_token_str).decode() or { panic(err) }
	if access_token.is_expired() {
		refresh_token_str := app.get_cookie('refresh_token') or { '' }
		access_token_str = app.session_client.new_access_token(refresh_token_str) or { panic(err) }
		app.set_cookie(name: 'access_token', value: access_token_str)
	}
	app.session_client.authenticate_access_token(access_token_str) or { panic(err) }
	username := jwt.SignedJWT(access_token_str).decode_subject() or { panic(err) }
	app.set_value('username', username)
	return true
}

@[middleware: get_username]
pub fn (mut app App) index() vweb.Result {
	login_form := '
	<form>
		<label for="username">Username</label>
		<input type="text" name="username"/>
		<label for="username">Username</label>
		<input type="password" name="password"/>
	</form>'
	username := app.get_value[string]('username') or { return app.html(login_form) }
	user_display := '<h1>${username}</h1>'
	return app.html(user_display)
}

@[POST]
pub fn (mut app App) login() !vweb.Result {
	data := http.parse_form(app.req.data)
	username := data['username']
	password := data['password']

	if username == 'admin' && password == '123456' {
		refresh_token := app.session_client.new_refresh_token(username)!
		access_token := app.session_client.new_access_token(refresh_token)!
		app.set_cookie(name: 'refresh_token', value: refresh_token)
		app.set_cookie(name: 'access_token', value: access_token)
		return app.html('Successfully logged in to ${username}!')
	}
	return app.html('Authentication failed')
}

fn main() {
	dir := os.dir(@FILE)
	if !os.exists('${dir}/static') {
		os.mkdir('${dir}/static')!
	}
	os.chdir('${dir}/static')!
	os.execute('curl -sLO https://raw.githubusercontent.com/freeflowuniverse/weblib/main/htmx/htmx.min.js')

	mut logger := log.Logger(&log.Log{
		level: .debug
	})

	mut session_ctrl := session.new_controller(&logger)
	// create and run app with authenticator
	mut app := &App{
		session_client: session.Client{'${host}/session_controller'}
		logger: &logger
		controllers: [
			vweb.controller('/session_controller', &session_ctrl),
		]
	}
	app.mount_static_folder_at('${dir}/static', '/static')
	vweb.run(app, port)
}
