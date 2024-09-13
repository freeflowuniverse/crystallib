module main

import net.smtp
import os
import freeflowuniverse.crystallib.security.authentication
import freeflowuniverse.crystallib.security.authorization {Permission}
import freeflowuniverse.webcomponents.view
import freeflowuniverse.crystallib.webserver.utils
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.webserver.auth.jwt { SignedJWT }
import veb
import json

pub struct Context {
	veb.Context
}

pub struct App {
	veb.Controller
pub:
	jwt_secret string = jwt.create_secret() // secret used for signing/verifying refresh tokens
mut:
	view view.View
	authenticator authentication.EmailClient
	authorizer authorization.Authorizer
	base_url string = 'localhost:8081'
}

pub struct EmailForm {
	email string
	remember_me bool
}

pub fn (mut app App) login_form(mut ctx Context) veb.Result {
	form := view.form[EmailForm]('/login')
	return ctx.html(form)
}

@[POST]
pub fn (mut app App) login(mut ctx Context) veb.Result {
	form := utils.decode_form[EmailForm](ctx.req.data)
	app.authenticator.send_verification_email(
		email: form.email
		callback: '${app.base_url}/callback'
	) or { panic(err)}
	return app.verification_mail_sent(mut ctx)
}

pub fn (mut app App) verification_mail_sent(mut ctx Context) veb.Result {
	return ctx.html('verification mail sent')
}

pub fn (mut app App) callback(mut ctx Context) veb.Result {
	// the jwt set by email authenticator
	auth_token := ctx.get_cookie('access_token') or {
		return app.authentication_failed(mut ctx, err.msg())
	}

	// validate token issued by email authentication server
	app.authenticator.validate_token(auth_token) or {
		return app.authentication_failed(mut ctx, err.msg())
	}

	decoded := SignedJWT(auth_token).decode() or {
		panic(err)
	}
	email_addr := decoded.sub
	token := app.create_access_token(email_addr) or {
		panic(err)
	}
	ctx.set_cookie(name:'access_token', value: token)
	return ctx.redirect('/assets')
}

pub fn (mut app App) assets(mut ctx Context, id string) veb.Result {
	return ctx.html('assets')
}

@['/assets/:id']
pub fn (mut app App) asset(mut ctx Context, id string) veb.Result {
	return ctx.html('assets')
}

pub fn (mut app App) authentication_failed(mut ctx Context, err string) veb.Result {
	return ctx.html(err)
}

pub fn (mut app App) create_access_token(user_id string) !string {
	permissions := app.authorizer.get_user_permissions(user_id)!
	token := jwt.create_token(
		sub: user_id
		data: json.encode(permissions)
	)
	return token.sign(app.jwt_secret)
}

fn new_app(app App) !&App{
    return &App{
		...app
	}
}

pub fn (mut app App) run(port int) {
    veb.run[App, Context](mut app, port)
}

fn get_smtp_client() smtp.Client {
	osal.load_env_file(os.dir(@FILE) + '/.env') or {
		panic('Could not find .env, ${err}')
	}
	return smtp.Client{
		server: 'smtp-relay.brevo.com'
		from: os.getenv('TEST_EMAIL')
		port: 587
		username: os.getenv('BREVO_SMTP_USERNAME')
		password: os.getenv('BREVO_SMTP_PASSWORD')
	}
}

pub fn (mut app App) is_authorized(mut ctx Context) bool {
	token := ctx.get_cookie('access_token') or {
		return false
	}
	verified := SignedJWT(token).verify(app.jwt_secret) or {
		return false
	}
	decoded := SignedJWT(token).decode() or {
		panic(err)
	}
	permissions := json.decode(map[string][]Permission, decoded.data) or {
		return false
	}
	
	resource_permissions := permissions[ctx.req.url]
	if resource_permissions.any(it == .read || it == .write) {
		return true
	}

	return false
}