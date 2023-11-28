module auth

import vweb
import json
import log

// session controller that be be added to vweb projects
pub struct Controller {
	vweb.Context
mut:
	authenticator Authenticator @[vweb_global]
	logger        &log.Logger = &log.Logger(&log.Log{
	level: .debug
})   @[vweb_global]
}

pub fn (mut app Controller) before_request() {
	app.logger.debug(app.req.url)
}

@[params]
pub struct ControllerConfig {
	logger        &log.Logger
	authenticator Authenticator @[required]
}

pub fn new_controller(config ControllerConfig) Controller {
	return Controller{
		logger: config.logger
		authenticator: config.authenticator
	}
}

@[POST]
pub fn (mut app Controller) new_auth_tokens() !vweb.Result {
	params := json.decode(RefreshTokenParams, app.req.data) or { panic('cant decode:${err}') }
	tokens := app.authenticator.new_auth_tokens(params)
	// refresh_token := app.authenticator.new_refresh_token(params)
	// access_token := app.authenticator.new_access_token(refresh_token: refresh_token)!
	// tokens := AuthTokens{
	// 	access_token: access_token
	// 	refresh_token: refresh_token
	// }
	return app.json(tokens)
	// return app.ok('')
}

// route responsible for verifying email, email form should be posted here
@[POST]
pub fn (mut app Controller) new_refresh_token() !vweb.Result {
	params := json.decode(RefreshTokenParams, app.req.data) or { panic('cant decode:${err}') }
	token := app.authenticator.new_refresh_token(params)
	return app.json(token)
}

@[POST]
pub fn (mut app Controller) new_access_token() !vweb.Result {
	params := json.decode(AccessTokenParams, app.req.data)!
	token := app.authenticator.new_access_token(params) or { return app.server_error(500) }
	return app.json(token)
	// return app.ok('')
}

@[POST]
pub fn (mut app Controller) authenticate_access_token() !vweb.Result {
	token := app.req.data
	app.authenticator.authenticate_access_token(token) or { return app.json(err.msg()) }
	return app.ok('Access token authenticated.')
	// return app.ok('')
}
