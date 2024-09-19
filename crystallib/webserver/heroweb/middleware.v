module heroweb

import freeflowuniverse.crystallib.webserver.auth.jwt
import veb

@['/protected/:path']
pub fn (mut app App) protected(mut ctx Context, path string) veb.Result {
	app.db.authorize(
		subject: ctx.user_id,
		object: path
		right: .read
	) or {
		return ctx.server_error(err.str())
	}
	println(app.db.users.values())
	return ctx.json(app.db.users[ctx.user_id])
}

// middleware to set user id to context from jwt
pub fn (app App) set_user(mut ctx Context) bool {	
    // get the cookie
    cookie_value := ctx.get_cookie('access_token') or { 
		return true
	}

	token := jwt.SignedJWT(cookie_value)
	verified := token.verify(app.jwt_secret) or {
		return true
 	}

	if !verified {
		return true
	}

 	user_id := token.decode_subject() or {
		return true
 	}
    
	ctx.user_id = user_id.u16()
    return true
}

// middleware to set user id to context from jwt
pub fn (app App) is_logged_in(mut ctx Context) bool {
    // get the cookie
	if ctx.user_id == 0 { 
		ctx.redirect('/signin')
		return false
	}

    return true
}