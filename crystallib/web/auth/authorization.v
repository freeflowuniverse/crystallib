module auth

import freeflowuniverse.crystallib.web.auth.authorization

pub struct AccessRequest {
	asset_id    string
	access_type authorization.AccessType
}

pub fn (mut app Authenticator) authorize(req AccessRequest) !bool {
	app.logger.debug('Authorizing access request ${req}')
	// todo
	user := app.get_user() or { return error('user not logged in') }
	return app.authorizer.authorize(
		accessor: user.id
	)
}

// pub fn (mut app Authenticator) authorize(req AccessRequest) !bool {
// 	app.logger.debug('Authorizing access request ${req}')
// 	// todo
// 	user := app.get_user() or { return error('user not logged in') }
// 	return app.authorizer.authorize(
// 		accessor: user.id
// 	)
// }

// TODO: protect_route and authorize_route
