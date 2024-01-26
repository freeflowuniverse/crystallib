module fskvs

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.crypt.aes_symmetric

@[heap]
pub struct DB {
pub mut:
	name      string
	path      pathlib.Path
	encrypted bool
	parent    &ContextDB   @[skip; str: skip]
}

pub fn (mut db DB) get(name_ string) !string {
	name := texttools.name_fix(name_)
	mut datafile := db.path.file_get_new(name)!
	mut data := datafile.read()!
	if data.len == 0 {
		return ''
	}
	if db.encrypted {
		data = aes_symmetric.decrypt_str(data, db.parent.secret)
	}
	return data
}

pub fn (mut db DB) set(name_ string, data_ string) ! {
	mut data := data_
	if data.len == 0 {
		return error('data cannot be empty')
	}
	name := texttools.name_fix(name_)
	mut datafile := db.path.file_get_new(name)!
	if db.encrypted {
		data = aes_symmetric.encrypt_str(data, db.parent.secret)
	}
	datafile.write(data)!
}

pub fn (mut db DB) exists(name_ string) bool {
	name := texttools.name_fix(name_)
	return db.path.file_exists(name)
}

pub fn (mut db DB) delete(name_ string) ! {
	name := texttools.name_fix(name_)
	mut datafile := db.path.file_get(name) or { return }
	datafile.delete()!
}

pub fn (mut db DB) keys() ![]string {
	mut r := db.path.list(recursive: false)!
	mut res := []string{}
	for item in r.paths {
		res << item.name()
	}
	return res
}

pub fn (mut db DB) prefix(prefix string) ![]string {
	mut res := []string{}
	for item in db.keys()! {
		// println(" ---- $item ($prefix)")
		if item.trim_space().starts_with(prefix) {
			// println("888")
			res << item
		}
	}
	return res
}

// delete all data
pub fn (mut db DB) destroy() ! {
	db.path.empty()!
}
