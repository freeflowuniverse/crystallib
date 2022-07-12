
module publisher_web

import freeflowuniverse.crystallib.publisher_core

struct WebServerContext {
pub mut:
	publisher &publisher_core.Publisher
	webnames  map[string]string   //what is this?
}

