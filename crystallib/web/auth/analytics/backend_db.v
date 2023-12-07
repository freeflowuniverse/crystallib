module analytics

import db.sqlite

@[noinit]
pub struct DBBackend {
mut:
	db sqlite.DB
}

@[params]
pub struct DBBackendConfig {
	db_path string = 'analytics.sqlite'
}

// factory for
pub fn new_backend(config DBBackendConfig) !DBBackend {
	db := sqlite.connect(config.db_path) or { panic(err) }

	sql db {
		create table Log
	} or { panic(err) }

	return DBBackend{
		db: db
	}
}

fn (mut backend DBBackend) create_log(log Log) Log {
	sql backend.db {
		insert log into Log
	} or { panic('Error insterting log ${log} into identity database:${err}') }
	return log
}
