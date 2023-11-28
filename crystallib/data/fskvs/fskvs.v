module fskvs

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import os

pub struct KVS {
pub mut:
	path pathlib.Path
}

@[params]
pub struct KVSArgs {
pub mut:
	name string = 'default'
}

pub fn new(args_ KVSArgs) !KVS {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	mut p := pathlib.get_dir(create: true, path: '${os.home_dir()}/hero/db/${args.name}')!
	mut db := KVS{
		path: p
	}
	return db
}

pub fn (mut db KVS) get(name_ string) !string {
	name := texttools.name_fix(name_)
	mut datafile := db.path.file_get_new(name)!
	data := datafile.read()!
	return data
}

pub fn (mut db KVS) set(name_ string, data string) ! {
	name := texttools.name_fix(name_)
	mut datafile := db.path.file_get_new(name)!
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
