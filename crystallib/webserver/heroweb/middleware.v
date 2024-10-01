module heroweb

import freeflowuniverse.crystallib.webserver.auth.jwt
import freeflowuniverse.crystallib.webserver.log
import veb
import time

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
		ctx.redirect('${app.base_url}/signin')
		return false
	}

    return true
}

// middleware to check if user is authorized to access an infopointer or asset
pub fn (app &App) is_authorized(mut ctx Context) bool {
	// if !app.is_logged_in(mut ctx) {
	// 	return false
	// }

	// if ctx.user_id == 0 {
	// 	panic('this should never happen as user must be logged in to reach this stage')
	// }



	infoptr_name := if ctx.req.url.starts_with('/asset/') {
		ctx.req.url.all_after('/asset/').all_before('/').all_before('?')
	} else if ctx.req.url.starts_with('/infopointer/') {
		ctx.req.url.all_after('/infopointer/').all_before('/').all_before('?')
	} else {
		panic('this should never happen')
	}

	if infoptr_name !in app.db.infopointers {
		ctx.res.set_status(.unauthorized)
		ctx.redirect('/unauthorized')
		return false
	}

	if app.db.authorize(
		subject: ctx.user_id
		object: infoptr_name
		right: .read
	) or {
		// TODO: report error
		ctx.server_error(err.str())
		return false
	} 
	{
		return true
	} else {
		ctx.res.set_status(.unauthorized)
		ctx.redirect('/unauthorized')
		return false
	}
	ctx.server_error('This should never happen')
    return false
}