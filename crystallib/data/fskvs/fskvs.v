module fskvs

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.crypt.aes_symmetric
import os

pub struct KVS {
pub mut:
	path   pathlib.Path
	secret string
}

@[params]
pub struct KVSArgs {
pub mut:
	name       string = 'default'
	secret     string
	encryption bool
}

// will check on evn variable "MYSECRET" if found will use to encrypt/decrypt .
// make sure to set secret if you don't want to use the 'MYSECRET' as mybe set in os.env arguments
pub fn new(args_ KVSArgs) !KVS {
	mut args := args_
	args.name = texttools.name_fix(args.name)

	if args.encryption {
		if 'MYSECRET' in os.environ() {
			args.secret = os.environ()['MYSECRET']
		} else {
			return error("'MYSECRET' not set in env, or not given to arguments.")
		}
	}

	mut p := pathlib.get_dir(create: true, path: '${os.home_dir()}/hero/db/${args.name}')!
	mut db := KVS{
		path: p
		secret: args.secret
	}
	return db
}

pub fn (mut db KVS) get(name_ string) !string {
	name := texttools.name_fix(name_)
	mut datafile := db.path.file_get_new(name)!
	mut data := datafile.read()!
	if db.secret.len > 0 {
		data = aes_symmetric.decrypt_str(data, db.secret)
	}
	return data
}

pub fn (mut db KVS) set(name_ string, data_ string) ! {
	mut data := data_
	name := texttools.name_fix(name_)
	mut datafile := db.path.file_get_new(name)!
	if db.secret.len > 0 {
		data = aes_symmetric.encrypt_str(data, db.secret)
		println(data)
		if true {
			panic('Sd')
		}
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

// delete all data
pub fn (mut db KVS) destroy() ! {
	db.path.empty()!
}
