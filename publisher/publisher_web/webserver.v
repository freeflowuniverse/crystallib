
module publisher_web

import vweb
import publisher.config

struct App {
	vweb.Context //dont understand this context
pub mut:
	ctx shared WebServerContext
}

pub fn (mut app App) index() vweb.Result {
	return app.handler('/')
}

// Run server (the starting point)
pub fn run(config config.ConfigRoot) ? {
	
	mut app := App{
		ctx: WebServerContext{
			config:config
		}	
	}

	// lock app.ctx {
	// 	app.ctx.domain_replacer_init()
	// }

	vweb.run(app, 8080)
}
