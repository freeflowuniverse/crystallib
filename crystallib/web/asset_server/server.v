module asset_server

import vweb
import freeflowuniverse.crystallib.web.auth { Authenticator }
import freeflowuniverse.crystallib.core.pathlib
import log

@[noinit]
pub struct AssetServer {
	vweb.Context
pub mut:
	auth   Authenticator @[required; vweb_global] // Authenticator to handle auth related functionality
	assets []Asset       @[required; vweb_global]
	logger &log.Logger = &log.Logger(&log.Log{
	level: .debug
})   @[vweb_global]
}

pub struct Asset {
	name string
	path string
	acl  auth.AccessControlList
}

pub struct AssetServerConfig {
	auth   Authenticator @[required] // Authenticator to be used
	assets []Asset       @[required]
	logger log.Logger
}

// new_asset_server configures and creates a new asset server
pub fn new(config AssetServerConfig) !AssetServer {
	mut access := map[string]auth.AccessControlList{}

	for asset in config.assets {
		access[asset.name] = asset.acl
	}

	authenticator := Authenticator{
		...config.auth
		access: access
	}
	mut server := AssetServer{
		auth: authenticator
		assets: config.assets
	}

	for asset in config.assets {
		source := pathlib.get(asset.path).absolute()
		mount := '/${asset.name}'
		server.mount_static_folder_at(source, mount)
	}
	return server
}

// before_request is a middleware that authorizes all requests made to asset endpoints
pub fn (mut server AssetServer) before_request() {
	server.auth.Context = server.Context

	authorized_urls := ['/', '/favicon.ico']
	if server.req.url !in authorized_urls {
		asset := server.req.url.trim_string_left('/').all_before('/')
		server.logger.info('Attempt to access asset: ${asset}')
		if !server.assets.any(it.name == asset) {
			server.logger.error('Asset ${asset} not found')
			server.not_found()
		}

		if user := server.auth.get_user() {
			if !server.auth.authorize(
				accessor: user.email
				asset_id: asset
				access_type: .read
			) {
				server.logger.error('Unauthorized access attempt to asset ${asset}')
				server.server_error(403)
			}
		} else {
			server.logger.error('User not logged in')
			server.server_error(403)
		}
	}
}

// wildcard path that handles all requests to assets
@['/:path...']
pub fn (mut server AssetServer) index(path string) vweb.Result {
	return server.html('ok')
}

pub fn (mut server AssetServer) not_found() vweb.Result {
	server.set_status(404, 'Not Found')
	return server.html($tmpl('./templates/404.html'))
}
