
module publisher
import publisher_web


// Run server (the starting point)
pub fn webserver_run(mut publisher Publisher) ? {
	
	publisher.check()?
	
	//get the most up to date static files
	publisher.config.update_staticfiles(false)?

	publisher_web.run(publisher.config)?
}
