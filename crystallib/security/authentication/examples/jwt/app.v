module main

import freeflowuniverse.crystallib.webtools.auth.email
import veb

pub struct Context {
	veb.Context
}

pub struct App {
	identity Identity
	authorizer Authorizer
	client EmailClient
}

pub struct EmailForm {
	email string
	remember_me bool
}

pub fn (mut app App) login_form(mut ctx Context) veb.Result {
	form := decode_form[EmailForm](ctx.req.data)
	email.send_verification_mail(form.email)
}

@[POST]
pub fn (mut app App) login(mut ctx Context) veb.Result {
	form := decode_form[EmailForm](ctx.req.data)
	email.send_verification_mail(form.email)
	return verification_mail_sent()
}

pub fn (mut app App) verification_mail_sent(mut ctx Context) veb.Result {
	return ctx.html('verification mail sent')
}

pub fn (mut app App) callback(mut ctx Context) veb.Result {
	access_token := ctx.get_cookie('access_token') or {
		return app.authentication_failed(mut ctx)
	}

	// validate token issued by email authentication server
	app.email_auth.validate_token(access_token) or {
		return app.authentication_failed(mut ctx)
	}

	token := SignedJWT(access_cookie)
	decoded := token.decode()
	email := token.subject
	user := app.create_user(email)!
	token := app.issue_access_token(user)
	ctx.set_cookie('access_token', token)
}

pub struct User {
	email string
	permissions map[string][]Permission
}

pub enum Permission {
	@none
	read
	write
}

pub fn (mut app App) create_access_token(email string) User {

	return User {
		email: email
		permissions: app.authorizer.get_user_permissions(email)
	}
}

pub fn (mut app App) get_permissions(email string) map[string][]Permission {
	return app.db.
} 

