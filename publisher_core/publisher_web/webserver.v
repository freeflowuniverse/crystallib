
module publisher_web
import publisher_core


struct App {
	vweb.Context
pub mut:
	ctx shared WebServerContext
}

pub fn (mut app App) index() vweb.Result {
	return app.handler('/')
}

// Run server (the starting point)
pub fn webserver_run(mut publisher Publisher) ? {
	
	publisher.check()?
	
	//get the most up to date static files
	publisher.config.update_staticfiles(false)?

	mut app := App{
		ctx: WebServerContext{
			publisher: &publisher
		}
	}

	// lock app.ctx {
	// 	app.ctx.domain_replacer_init()
	// }

	vweb.run(app, publisher.publisher.config.publish.port)
}
