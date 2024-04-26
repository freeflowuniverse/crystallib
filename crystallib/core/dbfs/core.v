module dbfs

import freeflowuniverse.crystallib.core.texttools

// will use default connection and get database with name as specified
// is not encrypted
pub fn db_get(name_ string) !DB {
	mut name := texttools.name_fix(name_)
	if name == '' {
		name = 'core'
	}

	mut defaultcollection := get()!

	mut db := defaultcollection.get(name)!

	if db.encrypted {
		return error('db is encrypted and should not be')
	}

	return db
}

// will use default connection and get database with name as specified, if not specified then name=core
// is not encrypted
pub fn db_secrets() !DB {
	mut defaultcollection := get()!

	mut db := defaultcollection.get('secrets')!

	db.encrypt()!

	return db
}
