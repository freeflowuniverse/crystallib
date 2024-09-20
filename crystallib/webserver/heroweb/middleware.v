module heroweb

import freeflowuniverse.crystallib.webserver.auth.jwt
import veb

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

// middleware to check if user is authorized to access an infopointer or asset
pub fn (app App) is_authorized(mut ctx Context) bool {
	if !app.is_logged_in(mut ctx) {
		return false
	}

	if ctx.user_id == 0 {
		panic('this should never happen')
	}

	infoptr_name := if ctx.req.url.starts_with('/assets/') {
		ctx.req.url.all_after('/assets/').all_before('/')
	} else if ctx.req.url.starts_with('/infopointer/') {
		ctx.req.url.all_after('/infopointer/').all_before('/')
	} else {
		panic('this should never happen')
	}

	if infoptr_name !in app.db.infopointers {
		ctx.res.set_status(.unauthorized)
		return false
	}

	if app.db.authorize(
		subject: ctx.user_id
		object: infoptr_name
		right: .read
	) or {
		// TODO: report error
		// ctx.server_error(err.str())
		return false
	} 
	{
	// 	app.db.logger.new_log(Log{
	// 		object: infoptr_name
	// 		subject: ctx.user_id.str() or {
	// 			return ctx.server_error(err.str())
	// 		}
	// 		message: 'access path ${app.req.url}'
	// 		event: 'view'
	// 	})
		return true
	} else {
		// ctx.res.set_status(.unauthorized)
		return false
	}





    return false
}