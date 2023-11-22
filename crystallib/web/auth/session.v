module auth

// import freeflowuniverse.spiderlib.auth.jwt
// import time
// import log

// // Authenticator deals and authenticates refresh and access tokens
// pub struct Authenticator {
// 	refresh_secret string = jwt.create_secret() // secret used for signing/verifying refresh tokens
// 	access_secret  string = jwt.create_secret() // secret used for signing/verifying refresh tokens
// mut:
// 	backend DatabaseBackend
// 	logger   &log.Logger = &log.Logger(&log.Log{
// 		level: .debug
// 	})
// 	sessions map[string][]string // maps subject's to users refresh tokens
// }

// [params]
// pub struct TokenParams {
// pub:
// 	user_id string // id of the user the token belongs to
// 	subject  string
// 	issuer   string
// 	audience string
// }

// [params]
// pub struct RefreshTokenParams {
// 	TokenParams
// pub:
// 	expiration time.Time
// }

// // secret := os.getenv('SECRET_KEY')

// pub struct AuthTokens {
// pub:
// 	access_token string
// 	refresh_token string
// }

// pub fn (mut auth Authenticator) new_refresh_token(params RefreshTokenParams) string {
// 	auth.logger.debug('Session authenticator: creating new refresh token')

// 	if !auth.backend.user_exists(params.user_id) {
// 		auth.backend.add_user(params.user_id)
// 	}

// 	auth.backend.add_session(
// 		id: rand.uuid_v4()
// 		user_id: params.user_id
// 	)

// 	token := jwt.create_token(
// 		sub: session_id
// 		iss: params.issuer
// 		exp: params.expiration
// 	)

// 	signed_token := token.sign(auth.refresh_secret)
// 	auth.logger.debug('Session authenticator: created refresh token: ${signed_token}')
// 	return signed_token
// }

// [params]
// pub struct AccessTokenParams {
// 	expiration    time.Time = time.now().add(15 * time.minute)
// 	refresh_token jwt.SignedJWT [required]
// }

// pub fn (mut auth Authenticator) new_access_token(params AccessTokenParams) !string {
// 	if !auth.authenticate_refresh_token(params.refresh_token)! {
// 		auth.logger.info('Session authenticator: Failed to authenticate refresh token')
// 		return error('Refresh token not authenticated')
// 	}
// 	refresh_token := params.refresh_token.decode()!
// 	token := jwt.create_token(
// 		sub: refresh_token.sub
// 		iss: refresh_token.iss
// 		exp: params.expiration
// 	)
// 	signed_token := token.sign(auth.access_secret)
// 	return signed_token
// }
