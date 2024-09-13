module authentication

import veb
import time
import json
import log



pub struct Context {
    veb.Context
}

// email authentication server that be be added to veb projects
pub struct Server {
	base_url string 
mut:
	authenticator Authenticator
}

pub struct ServerConfig {
	AuthenticatorConfig
pub:
	base_url string @[required]
}

pub fn new_server(config ServerConfig) !&Server {
	return &Server{
		authenticator: new(config.AuthenticatorConfig)!
		base_url: config.base_url
	}
	// return &app
}

// route responsible for verifying email, email form should be posted here
[POST]
pub fn (mut app Server) send_verification_mail(mut ctx Context) veb.Result {
	config := json.decode(SendMailConfig, ctx.req.data) or {panic(err)}
	println('got config ${config}')
	app.authenticator.send_verification_mail(SendMailConfig{
		...config
		link: '${app.base_url}/authentication_link'
	}) or { panic(err) }
	println('Sent verification email')
	return ctx.ok('')
}

['/authentication_link/:address/:cypher/:callback']
pub fn (mut app Server) authentication_link(mut ctx Context, address string, cypher string, callback string) veb.Result {
	app.authenticator.authenticate(address, cypher) or {
		return ctx.text('Failed to authenticate ${err}')
	}
	println('Authentication successful ${callback}')
	return ctx.redirect(callback)
}

pub fn (app &Server) index(mut ctx Context) veb.Result {
	return ctx.html('hello')
}

pub fn (mut app Server) run(port int) ! {
    veb.run[Server, Context](mut app, port)
}
