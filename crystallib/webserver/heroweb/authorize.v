module heroweb

import veb

@['/fileserver/:path']
pub fn (mut app App) fileserver(mut ctx Context, path string) veb.Result {
	app.authorizer.authorize(
		subject: ctx.user_id,
		object: path
		right: .read
	) or {
		return ctx.server_error(err.str())
	}
	return ctx.
}

// middleware to set user id to context from jwt
pub fn set_user(mut ctx Context) bool {
    // get the cookie
    cookie_value := ctx.get_cookie('access_token') or { 
		ctx.redirect('/signin')
		return false
	}

	token := SignedJWT(cookie_value)
	verified := token.verify(c.secret) or {
 		return error('Failed to verify jwt. ${err}')
 	}

	if !verified {
		ctx.redirect('/signin')
		return false
	}


 	user_id := token.decode_subject() or {
 		ctx.server_error(err)
		return false
 	}
    
	context.user_id = user_id
    return true
}