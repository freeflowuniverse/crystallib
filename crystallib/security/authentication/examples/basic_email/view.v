module main

import freeflowuniverse.spiderlib.auth.email
import net.http
import vweb

// Example vweb application with Email Authenticator
struct EmailApp {
	vweb.Context
	auth shared email.Authenticator
}

// home page, nothing but an email form that posts input to /login
pub fn (mut app EmailApp) index() vweb.Result {
	verify_path := '/email_verification'
	return $vweb.html()
}

struct EmailForm {
	email string
}

// login route, sends verification email to the input posted, returns status message
[POST]
pub fn (mut app EmailApp) email_verification() !vweb.Result {
	data := http.parse_form(app.req.data)
	verified := app.verify_email(data['email']) or {
		return app.server_error(500)
	}
	if !verified {
		app.set_status(401, 'failed to verify email')
	}
	return app.html('Successfully verified email.')
}

['/authentication_link/:address/:cypher']
pub fn (mut app EmailApp) authentication_link(address string, cypher string) !vweb.Result {
	authenticated := app.authenticate(address, cypher)
	if !authenticated {
		app.set_status(401, 'failed to verify email')
		return app.text('failed to verify email')
	}
	return app.html('Email verified')
}

pub fn (mut app EmailApp) not_found() vweb.Result {
	app.set_status(404, 'Not Found')
	return app.html('<h1>Page not found</h1>')
}