module dbfs

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.crypt.aes_symmetric

@[heap]
pub struct DB {
pub mut:
	dbname      string
	path      pathlib.Path
	encrypted bool
	parent    &DBCollection @[skip; str: skip]
}

// get the value, if it doesn't exist then return empty string
pub fn (mut db DB) get(key_ string) !string {
	key := texttools.name_fix(key_)
	if !db.exists(key) {
		return ''
	}
	mut datafile := db.path.file_get_new(key)!
	mut data := datafile.read()!
	if data.len == 0 {
		panic('data cannot be empty for get:${key}')
	}
	if db.encrypted {
		data = aes_symmetric.decrypt_str(data, db.secret()!)
	}
	return data
}

// set the key/value will go to filesystem, is organzed per context and each db has a name
// if key empty then will be an autoincrement resulting in a sid, this will be based on the participant nr
pub fn (mut db DB) set(key_ string, data_ string) ! {
	mut data := data_
	if data.len == 0 {
		panic('data cannot be empty for set:${key_}')
	}
	if data.len == 0 {
		return error('data cannot be empty for set:${key_}')
	}
	key := texttools.name_fix(key_)
	mut datafile := db.path.file_get_new(key)!
	if db.encrypted {
		data = aes_symmetric.encrypt_str(data, db.secret()!)
	}
	datafile.write(data)!
}

// check if entry exists based on keyname
pub fn (mut db DB) exists(key_ string) bool {
	key := texttools.name_fix(key_)
	if !(db.path.file_exists(key)) {
		return false
	}
	mut datafile := db.path.file_get(key) or { panic(err) }
	mut data := datafile.read() or { panic(err) }
	if data.len == 0 {
		datafile.delete() or { panic(err) }
		return false
	}
	return true
}

// delete an entry
pub fn (mut db DB) delete(key_ string) ! {
	key := texttools.name_fix(key_)
	mut datafile := db.path.file_get(key) or { return }
	datafile.delete()!
}

// delete the db, will not be able to use it any longer
pub fn (mut db DB) destroy() ! {
	db.path.delete()!
}

// get all keys of the db (e.g. per session) can be with a prefix
pub fn (mut db DB) keys(prefix_ string) ![]string {
	prefix := texttools.name_fix(prefix_)
	mut r := db.path.list(recursive: false)!
	mut res := []string{}
	for item in r.paths {
		name := item.name()
		if prefix == '' || name.starts_with(prefix) {
			res << name
		}
	}
	return res
}

// delete all data
pub fn (mut db DB) empty() ! {
	db.path.empty()!
	if db.encrypted {
		// need to make sure we restore the encrypted file
		db.path.file_get_new('encrypted')!
	}
}

fn (mut db DB) secret() !string {
	if db.encrypted {
		return db.parent.secret
	}
	return ''
}

// will mark db for encryption .
// will go over all existing keys and encrypt
pub fn (mut db DB) encrypt() ! {
	if db.encrypted {
		return
	}
	db.secret()! // just to check if ok
	for key in db.keys('')! {
		db.encrypted = false
		v := db.get(key)!
		db.encrypted = true
		db.set(key, v)!
	}
	db.encrypted = true
	db.path.file_get_new('encrypted')!
}


pub fn (mut db DB) encrypt() ! {
	if db.encrypted {
		return
	}
	db.secret()! // just to check if ok
	for key in db.keys('')! {
		db.encrypted = false
		v := db.get(key)!
		db.encrypted = true
		db.set(key, v)!
	}
	db.encrypted = true
	db.path.file_get_new('encrypted')!
}

		incr_file:=dbcollection.path.file_get_new("incr_${memberid}")!