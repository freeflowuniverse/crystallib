module session

import db.sqlite
import log
import rand
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct SessionConfig {
	backend ?DatabaseBackend
}

pub fn new(config SessionConfig) !SessionAuth {
	console.print_debug('funky')
	console.print_debug(config.backend)
	return SessionAuth{
		backend: config.backend or { new_database_backend()! }
	}
}
