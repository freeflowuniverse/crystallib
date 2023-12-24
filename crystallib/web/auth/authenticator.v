module auth

import freeflowuniverse.spiderlib.auth.jwt { SignedJWT }
import freeflowuniverse.crystallib.web.auth.analytics
import freeflowuniverse.crystallib.web.auth.tokens
import freeflowuniverse.crystallib.web.auth.email
import freeflowuniverse.crystallib.web.auth.session
import freeflowuniverse.crystallib.web.auth.identity
import net.http
import time
import log
import rand
import db.sqlite
import vweb

pub fn (mut auth Authenticator) authenticate(context vweb.Context) ! {
	access_token := auth.get_access_token(context) or { return error('not found') }
	auth.tokens.authenticate_access_token(access_token) or {
		return error('failed to authenticate access token')
	}
}

pub fn (mut auth Authenticator) get_user(context vweb.Context) !identity.User {
	access_token := auth.get_access_token(context) or { return error('not found') }
	auth.tokens.authenticate_access_token(access_token) or {
		auth.logger.debug('Failed to authenticate token ${err}')
		return error('error')
	}

	token := SignedJWT(access_token).decode() or { panic('this should never happen') }
	sesh := auth.session.get_session(token.sub) or {
		auth.logger.debug('Failed to get session from access token')
		return error('error')
	}
	user := auth.identity.get_user(id: sesh.user_id) or {
		auth.logger.debug('Failed to get user')
		return error('error')
	}
	return user
}

pub struct Registration {
	user   identity.User
	tokens tokens.AuthTokens
}

//
pub fn (mut auth Authenticator) register(identifier string) !Registration {
	user := auth.identity.register_user(identifier)
	sesh := auth.session.create_session(user.id)
	tkns := auth.tokens.new_auth_tokens(
		subject: sesh.session_id
	)
	return Registration{
		user: user
		tokens: tkns
	}
}

pub fn (mut auth Authenticator) login_challenge(config email.SendMailConfig) ! {
	auth.email or { return error('error') }.send_verification_mail(config)!
}

pub fn (mut auth Authenticator) login(identifier string) !Registration {
	auth.email or { return error('error') }.email_authentication()!
	user := auth.identity.login_user(identifier)!
	sesh := auth.session.create_session(user.id)
	tkns := auth.tokens.new_auth_tokens(
		subject: sesh.session_id
	)
	return Registration{
		user: user
		tokens: tkns
	}
}

// TODO
// log_analytics logs analytic related logs
pub fn (mut app Authenticator) log_analytics(context vweb.Context) ! {
	user := app.get_user(context)!
	app.analytics.log(
		subject: user.id
		object: 'app.req.url'
		event: .http_request
	)
}

pub fn (mut app Authenticator) get_access_token(context vweb.Context) ?SignedJWT {
	mut access_token_str := context.get_cookie('access_token') or {
		// logger.debug('Access token coookie not found.')
		return none
	}
	access_token := SignedJWT(access_token_str).decode() or {
		// logger.error('Failed to decode user\'s access token: ${err}')
		return none
	}
	if access_token.is_expired() {
		app.logger.debug('Access token is expired, fetching new access token.')
		refresh_token_str := context.get_cookie('refresh_token') or {
			app.logger.error('Refresh token cookie not found.')
			return none
		}
		refresh_token := SignedJWT(refresh_token_str).decode() or {
			app.logger.error('Failed to decode user\'s refresh token: ${err}')
			return none
		}
		if refresh_token.is_expired() {
			app.logger.debug('Refresh token is expired, user must authenticate to create new session')
			return none
		}
		access_token_str = app.tokens.new_access_token(refresh_token: refresh_token_str) or {
			app.logger.error('Failed to create new access token: ${err}')
			return none
		}
		// todo
		// context.set_cookie(name: 'access_token', value: access_token_str)
	}
	return SignedJWT(access_token_str)
}
