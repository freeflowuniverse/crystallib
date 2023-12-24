module auth

import freeflowuniverse.crystallib.web.auth.identity
import vweb

pub fn (mut app Authenticator) before_request() {
	// app.authorize()!
	hx_request := app.get_header('Hx-Request') == 'true'
	if !hx_request && app.req.url != '/admin' {
		app.index()
	}
}

pub fn (mut app Authenticator) index() vweb.Result {
	route := if app.req.url == '/admin' {
		'home'
	} else {
		app.req.url
	}

	return $vweb.html()
}

pub fn (mut app Authenticator) users() vweb.Result {
	users := app.identity.get_users() or { return app.server_error(500) }
	return $vweb.html()
}

pub fn (mut app Authenticator) analytics() vweb.Result {
	users := app.identity.get_users() or { return app.server_error(500) }
	return $vweb.html()
}

pub fn (mut app Authenticator) add_user_form() vweb.Result {
	return app.html($tmpl('./templates/add_user_form.html'))
}
