module auth

import freeflowuniverse.spiderlib.auth.jwt
import freeflowuniverse.crystallib.web.auth.email
import freeflowuniverse.crystallib.web.auth.identity
import time
import log
import rand
import db.sqlite
import vweb

// Authenticator deals and authenticates refresh and access tokens
pub struct Authenticator {
	vweb.Context
	refresh_secret string = jwt.create_secret() // secret used for signing/verifying refresh tokens
	access_secret  string = jwt.create_secret() // secret used for signing/verifying refresh tokens
pub mut:
	identity identity.IdentityManager
	email    ?email.EmailAuthenticator
	access   map[string]AccessControlList
	backend  DatabaseBackend
	logger   &log.Logger = &log.Logger(&log.Log{
	level: .debug
})
}

@[params]
pub struct AuthenticatorConfig {
	refresh_secret string = jwt.create_secret() // secret used for signing/verifying refresh tokens
	access_secret  string = jwt.create_secret() // secret used for signing/verifying refresh tokens
	access         map[string]AccessControlList //
	// backend        DatabaseBackend [required]
	logger &log.Logger = &log.Logger(&log.Log{
	level: .debug
})
}

pub fn new(config AuthenticatorConfig) !Authenticator {
	return Authenticator{
		identity: identity.new()!
		access_secret: config.access_secret
		refresh_secret: config.refresh_secret
		backend: new_database_backend()!
		logger: config.logger
		email: email.new(backend: email.new_database_backend()!)
		access: config.access
	}
}

@[params]
pub struct TokenParams {
pub:
	user_id  string
	subject  string
	issuer   string
	audience string
}

@[params]
pub struct RefreshTokenParams {
	TokenParams
pub:
	expiration time.Time = time.now().add_days(30)
mut:
	db sqlite.DB
}

// secret := os.getenv('SECRET_KEY')

pub struct AuthTokens {
pub:
	access_token  string
	refresh_token string
}

pub fn (mut auth Authenticator) new_auth_tokens(params RefreshTokenParams) AuthTokens {
	auth.logger.debug('Session authenticator: creating new auth tokens')
	refresh_token := auth.new_refresh_token(params)
	access_token := auth.new_access_token(refresh_token: refresh_token) or { panic(err) }
	return AuthTokens{
		access_token: access_token
		refresh_token: refresh_token
	}
}

pub fn (mut auth Authenticator) new_refresh_token(params RefreshTokenParams) string {
	auth.logger.debug('Session authenticator: creating new refresh token')

	// if !auth.backend.user_exists(params.user_id) {
	// 	auth.backend.add_user(params.user_id)
	// }

	session_id := rand.uuid_v4()

	auth.backend.add_session(
		session_id: session_id
		user_id: params.user_id
		fid: 1
	)

	token := jwt.create_token(
		sub: session_id
		iss: params.issuer
		exp: params.expiration
	)

	signed_token := token.sign(auth.refresh_secret)
	auth.logger.debug('Session authenticator: created refresh token: ${signed_token}')
	return signed_token
}

@[params]
pub struct AccessTokenParams {
	expiration    time.Time = time.now().add(15 * time.minute)
	refresh_token jwt.SignedJWT @[required]
}

pub fn (mut auth Authenticator) new_access_token(params AccessTokenParams) !string {
	if !auth.authenticate_refresh_token(params.refresh_token)! {
		auth.logger.info('Session authenticator: Failed to authenticate refresh token')
		return error('Refresh token not authenticated')
	}
	refresh_token := params.refresh_token.decode()!
	token := jwt.create_token(
		sub: refresh_token.sub
		iss: refresh_token.sub
		exp: params.expiration
	)
	signed_token := token.sign(auth.access_secret)
	return signed_token
}

fn (mut auth Authenticator) authenticate_refresh_token(token jwt.SignedJWT) !bool {
	if !token.verify(auth.refresh_secret)! {
		auth.logger.debug('Session authenticator: Failed to verify signature of refresh token')
		return false
	}
	decoded_token := token.decode() or {
		panic('Session authenticator: Failed to decode token:\n ${err}')
	}
	if decoded_token.is_expired() {
		auth.logger.debug('Session authenticator: Refresh token has expired')
		return false
	}
	if !auth.backend.session_exists(decoded_token.sub) {
		auth.logger.debug('Session authenticator: Session id not found.')
		return false
	}
	return true
}

// authenticate_access_token authenticates an access token and
// verifies that the session which issued the token is still valid
pub fn (mut auth Authenticator) authenticate_access_token(token jwt.SignedJWT) ! {
	decoded_token1 := token.decode() or {
		panic('Session authenticator: Failed to decode access token:\n ${err}')
	}
	auth.logger.debug('Authenticating access token: ${token}')
	if !token.verify(auth.access_secret)! {
		auth.logger.info('Failed to verify access token')
		return error('Failed to verify access token')
	}
	decoded_token := token.decode() or {
		panic('Session authenticator: Failed to decode access token:\n ${err}')
	}

	// the issuer of an access token is the session id of the
	// refresh token that issued the access token
	if !auth.backend.session_exists(decoded_token.iss) {
		auth.logger.debug("Session authenticator: session doesn't exist.")
		return error('session doesnt exist')
	}
}

pub fn (mut auth Authenticator) revoke_refresh_token(token jwt.SignedJWT) ! {
	auth.authenticate_refresh_token(token)!
	auth.backend.delete_session('${token.decode_subject()!}')
}

pub fn (mut auth Authenticator) get_access_token() ?jwt.SignedJWT {
	mut access_token_str := auth.get_cookie('access_token') or {
		auth.logger.debug('Access token coookie not found.')
		return none
	}
	access_token := jwt.SignedJWT(access_token_str).decode() or {
		auth.logger.error('Failed to decode user\'s access token: ${err}')
		return none
	}
	if access_token.is_expired() {
		auth.logger.debug('Access token is expired, fetching new access token.')
		refresh_token_str := auth.get_cookie('refresh_token') or {
			auth.logger.error('Refresh token cookie not found.')
			return none
		}
		refresh_token := jwt.SignedJWT(refresh_token_str).decode() or {
			auth.logger.error('Failed to decode user\'s refresh token: ${err}')
			return none
		}
		if refresh_token.is_expired() {
			auth.logger.debug('Refresh token is expired, user must authenticate to create new session')
			return none
		}
		access_token_str = auth.new_access_token(refresh_token: refresh_token_str) or {
			auth.logger.error('Failed to create new access token: ${err}')
			return none
		}
		auth.set_cookie(name: 'access_token', value: access_token_str)
	}
	return jwt.SignedJWT(access_token_str)
}

pub fn (mut auth Authenticator) authenticate() bool {
	access_token := auth.get_access_token() or { return false }

	auth.authenticate_access_token(access_token) or { return false }

	return true
}

pub fn (mut auth Authenticator) get_session(session_id string) ?Session {
	return auth.backend.get_session(session_id)
}

pub fn (mut server Authenticator) login() vweb.Result {
	return server.html('wowzy!')
}

pub fn (mut auth Authenticator) get_user() !identity.User {
	access_token := auth.get_access_token() or {
		auth.logger.debug('Failed to get access token: ${err}')
		return error('error')
	}
	auth.authenticate_access_token(access_token) or {
		auth.logger.debug('Failed to authenticate token ${err}')
		return error('error')
	}

	token := access_token.decode() or { panic('this should never happen') }
	session := auth.get_session(token.sub) or {
		auth.logger.debug('Failed to get session from access token')
		return error('error')
	}
	println('getting user: ${session}')
	user := auth.identity.get_user(id: session.user_id) or {
		auth.logger.debug('Failed to get user')
		return error('error')
	}
	return user
}
