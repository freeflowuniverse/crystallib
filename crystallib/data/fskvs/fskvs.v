module fskvs

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.crypt.aes_symmetric

@[heap]
pub struct KVS {
pub mut:
	name       string
	path       pathlib.Path
	encryption bool
	parent     &KVSContext  @[skip; str: skip]
}

@[params]
pub struct KVSGet {
pub mut:
	name       string = 'default'
	encryption bool
}

// get a KVS from the context
pub fn (mut db KVSContext) get(args_ KVSGet) !KVS {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	mut p := pathlib.get_dir(create: true, path: '${db.path.path}/${args.name}')!
	mut db2 := KVS{
		name: args.name
		path: p
		encryption: args.encryption
		parent: &db
	}
	if args.encryption {
		assert db.config.secret.len > 3
	}
	return db2
}

pub fn (mut db KVS) get(name_ string) !string {
	name := texttools.name_fix(name_)
	mut datafile := db.path.file_get_new(name)!
	mut data := datafile.read()!
	if data.len == 0 {
		return ''
	}
	if db.encryption {
		data = aes_symmetric.decrypt_str(data, db.parent.config.secret)
	}
	return data
}

pub fn (mut db KVS) set(name_ string, data_ string) ! {
	mut data := data_
	if data.len == 0 {
		return error('data cannot be empty')
	}
	name := texttools.name_fix(name_)
	mut datafile := db.path.file_get_new(name)!
	if db.encryption {
		data = aes_symmetric.encrypt_str(data, db.parent.config.secret)
	}
	datafile.write(data)!
}

pub fn (mut db KVS) exists(name_ string) bool {
	name := texttools.name_fix(name_)
	return db.path.file_exists(name)
}

pub fn (mut db KVS) delete(name_ string) ! {
	name := texttools.name_fix(name_)
	mut datafile := db.path.file_get(name) or { return }
	datafile.delete()!
}

pub fn (mut db KVS) keys() ![]string {
	mut r := db.path.list(recursive: false)!
	mut res := []string{}
	for item in r.paths {
		res << item.name()
	}
	return res
}

pub fn (mut db KVS) prefix(prefix string) ![]string {
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
pub fn (mut db KVS) destroy() ! {
	db.path.empty()!
}
