module meet

import freeflowuniverse.crystallib.osal
import veb
import rand
import os
import json
import freeflowuniverse.crystallib.webserver.auth.jwt
import time

// Context struct embedding `veb.Context`
pub struct Context {
	veb.Context
}

// App struct with `livekit.Client`, API keys, and other shared data
pub struct App {
	veb.StaticHandler
pub:
	static_url string = 'https://freeflowuniverse.github.io/livekit_meet'
	livekit_url string @[required]
	api_key        string
	api_secret     string
}

pub struct AppConfig {
pub:
	livekit_url string @[required]
	livekit_api_key string @[required]
	livekit_api_secret string @[required]
}

// Main entry point
pub fn new(config AppConfig) &App {
	update_templates() or {
		panic(err)
	}
	mut app := &App{
		livekit_url: config.livekit_url
		api_key:  config.livekit_api_key
		api_secret: config.livekit_api_secret
	}
	// Start the Veb web server on port 8080
	app.static_mime_types['.map'] = 'txt/plain'

	app.mount_static_folder_at('${os.dir(@FILE)}/static','/static') or {
		panic(err)
	}

	return app
}

@[params]
pub struct RunParams {
	port int = 8080
}

pub fn (mut app App) run(params RunParams) {
	veb.run[App, Context](mut app, params.port)
}
