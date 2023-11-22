module auth

import freeflowuniverse.spiderlib.auth.jwt
import log
import time

fn test_new() {
	mut logger := log.Logger(&log.Log{
		level: .debug
	})
	auth := Authenticator{
		logger: &logger
		backend: new_database_backend()!
	}
}

fn test_session_authenticator() {
	mut logger := log.Logger(&log.Log{
		level: .debug
	})
	mut auth := Authenticator{
		logger: &logger
		backend: new_database_backend()!
	}
	token := auth.new_refresh_token(
		subject: 'subject'
		issuer: 'test'
	)
	assert refresh_token_works(mut auth, token)

	time.sleep(2 * time.second)

	// new refresh token, old refresh token should still work
	token1 := auth.new_refresh_token(
		subject: 'subject'
		issuer: 'test'
	)
	assert refresh_token_works(mut auth, token)
	assert refresh_token_works(mut auth, token1)

	// refresh token revoked, should no longer work
	auth.revoke_refresh_token(token1)!
	assert !refresh_token_works(mut auth, token1)
}

fn refresh_token_works(mut auth Authenticator, token string) bool {
	mut works := true
	signed_jwt := jwt.SignedJWT(token)
	works = works && signed_jwt.is_valid()
	works = works && auth.authenticate_refresh_token(signed_jwt) or { return false }
	access_token := auth.new_access_token(AccessTokenParams{
		refresh_token: signed_jwt
	}) or { return false }
	signed_access := jwt.SignedJWT(access_token)
	auth.authenticate_access_token(signed_access) or { return false }
	return works
}
