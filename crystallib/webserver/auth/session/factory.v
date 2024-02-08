module session

import db.sqlite
import log
import rand

@[params]
pub struct SessionConfig {
	backend ?DatabaseBackend
}

pub fn new(config SessionConfig) !SessionAuth {
	println('funky')
	println(config.backend)
	return SessionAuth{
		backend: config.backend or { new_database_backend()! }
	}
}
