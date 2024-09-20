module log

import db.sqlite

pub struct Logger {
	db_path string
	// DBBackend
}

pub fn new(db_path string) !Logger {
	// db := sqlite.connect(db_path)!
	return Logger{
		db_path: db_path
		// DBBackend: new_backend(db: db)!
	}
}
