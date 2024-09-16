module heroweb

import time
import freeflowuniverse.crystallib.webserver.auth.jwt
import freeflowuniverse.crystallib.security.authentication
import veb

@['/register'; post]
pub fn (mut app App) register(mut ctx Context) veb.Result {
	email := ctx.form['email'] or { return ctx.text('Email is required') }
	app.authenticator.send_authentication_mail(
		to: email
		callback: '${app.base_url}/callback'
	) or {
		return ctx.text('${err}')
	}
	return ctx.html("Check your email for the verification link")
}

@['/callback/:email/:expiration/:signature']
pub fn (mut app App) callback(mut ctx Context, email string, expiration string, signature string) veb.Result {
	app.authenticator.authenticate(
		email: email
		expiration: time.unix(expiration.i64())
		signature: signature
	) or {
		return ctx.text('${err}')
	}
	
	id := app.authorizer.get_user_id(email: [email]) or {
		app.authorizer.user_add(name: email, email: email) or {
			return ctx.server_error('${err}')
		}
	}
	token := jwt.create_token(sub: id.str())
	return ctx.redirect('/')
}


@['/signin']
pub fn (app &App) signin(mut ctx Context) veb.Result {
	d:=$tmpl("templates/login.html")
	return ctx.html(d)
}
