module heroweb

import time
import freeflowuniverse.crystallib.webserver.auth.jwt
import freeflowuniverse.crystallib.webserver.auth.authentication.email as email_authentication
import veb

@['/register'; post]
pub fn (mut app App) register(mut ctx Context) veb.Result {
	email := ctx.form['email'] or { return ctx.text('Email is required') }
	app.db.authenticator.send_authentication_mail(
		to: email
		callback: '${app.base_url}/callback'
	) or {
		return ctx.text('${err}')
	}
	return app.authentication_mail_sent(mut ctx, email)
}

@['/callback/:email/:expiration/:signature']
pub fn (mut app App) callback(mut ctx Context, email string, expiration string, signature string) veb.Result {
	app.db.authenticator.authenticate(
		email: email
		expiration: time.unix(expiration.i64())
		signature: signature
	) or {
		return ctx.text('${err}')
	}
	
	id := app.db.get_user_id(email: [email]) or {
		app.db.user_add(name: email, email: email) or {
			return ctx.server_error('${err}')
		}
	}
	token := jwt.create_token(sub: id.str())
	signed_token := token.sign(app.jwt_secret)
	
	ctx.set_cookie(name: 'access_token', value: signed_token, path: '/')
	return ctx.redirect('/view/assets')
}