module heroweb

import time
import freeflowuniverse.crystallib.webserver.auth.jwt
import freeflowuniverse.crystallib.webserver.auth.authentication.email as email_authentication
import veb

pub fn (mut app App) authentication_mail_sent(mut ctx Context, email string) veb.Result {
	return ctx.html($tmpl('./templates/mail_sent.html'))
}

@['/signin']
pub fn (app &App) signin(mut ctx Context) veb.Result {
	d:=$tmpl("templates/login.html")
	return ctx.html(d)
}
