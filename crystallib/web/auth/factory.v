module auth

import freeflowuniverse.spiderlib.auth.jwt
import freeflowuniverse.crystallib.web.auth.email
import freeflowuniverse.crystallib.web.auth.session
import freeflowuniverse.crystallib.web.auth.tokens
import freeflowuniverse.crystallib.web.auth.authorization
import freeflowuniverse.crystallib.web.auth.analytics
import freeflowuniverse.crystallib.web.auth.identity
import net.http
import time
import log
import rand
import db.sqlite
import vweb

// Authenticator deals and authenticates refresh and access tokens
pub struct Authenticator {
	// vweb.Context
	refresh_secret string = jwt.create_secret() // secret used for signing/verifying refresh tokens
	access_secret  string = jwt.create_secret() // secret used for signing/verifying refresh tokens
pub mut:
	identity   identity.IdentityManager @[vweb_global]
	email      ?email.Authenticator     @[vweb_global]
	analytics  analytics.Analyzer       @[vweb_global]
	authorizer authorization.Authorizer @[vweb_global]
	session    session.SessionAuth      @[vweb_global]
	tokens     tokens.Tokens            @[vweb_global]
	route      string
	// backend   DatabaseBackend
	logger &log.Logger = &log.Logger(&log.Log{
	level: .debug
})
}

@[params]
pub struct AuthenticatorConfig {
	email.AuthenticatorConfig
	refresh_secret string = jwt.create_secret() // secret used for signing/verifying refresh tokens
	access_secret  string = jwt.create_secret() // secret used for signing/verifying refresh tokens
	authorizer     authorization.Authorizer
	// backend        DatabaseBackend [required]
	logger &log.Logger = &log.Logger(&log.Log{
	level: .debug
})
}

pub fn new(config AuthenticatorConfig) !Authenticator {
	return Authenticator{
		identity: identity.new()!
		analytics: analytics.new()!
		access_secret: config.access_secret
		session: session.new()!
		refresh_secret: config.refresh_secret
		// backend: new_database_backend()!
		logger: config.logger
		email: email.new(
			smtp: config.smtp
			backend: email.new_database_backend()!
		)!
		authorizer: config.authorizer
	}
}
