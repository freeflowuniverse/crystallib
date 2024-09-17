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
		ctx.redirect('/signin')
		return false
	}

	token := jwt.SignedJWT(cookie_value)
	verified := token.verify(app.jwt_secret) or {
 		ctx.server_error('Failed to verify jwt. ${err}')
		return false
 	}

	if !verified {
		ctx.redirect('/signin')
		return false
	}

 	user_id := token.decode_subject() or {
 		ctx.server_error(err.str())
		return false
 	}
    
	ctx.user_id = user_id.u16()
    return true
}