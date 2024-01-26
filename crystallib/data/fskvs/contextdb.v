module fskvs

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import os

@[heap]
pub struct ContextDB {
pub mut:
	path   pathlib.Path
	name   string
	secret string
}

@[params]
pub struct DBConfigureArgs {
pub mut:
	dbname    string = 'default'
	encrypted bool
}

// get a DB from the contextdb, will configure encrypted if set, default is false
pub fn (mut db ContextDB) db_configure(args_ DBConfigureArgs) ! {
	mut args := args_
	args.dbname = texttools.name_fix(args.dbname)
	pathlib.get_dir(create: true, path: '${db.path.path}/${args.dbname}')!
	if args.encrypted {
		// put pointer that encrypted is on
		pathlib.get_file(create: true, path: '${db.path.path}/${args.dbname}/encrypted')!
	} else {
		mut p2 := pathlib.get_file(create: false, path: '${db.path.path}/${args.dbname}/encrypted') or {
			return
		}
		p2.delete()!
	}
}

@[params]
pub struct DBGetArgs {
pub mut:
	dbname string = 'default'
}

// get a DB from the contextdb
pub fn (mut db ContextDB) db_get(args_ DBGetArgs) !DB {
	mut args := args_
	args.dbname = texttools.name_fix(args.dbname)
	mut p := pathlib.get_dir(create: true, path: '${db.path.path}/${args.dbname}')!
	mut encrypted := false
	if os.exists('${db.path.path}/${args.dbname}/encrypted') {
		encrypted = true
	}
	mut db2 := DB{
		name: args.dbname
		path: p
		encrypted: encrypted
		parent: &db
	}
	if encrypted {
		if db.secret.len < 4 {
			return error('secret needs to be specified on contextdb level, now < 4 chars. \nDB: ${db}')
		}
	}
	return db2
}

pub fn (mut db ContextDB) db_exists(name_ string) bool {
	name := texttools.name_fix(name_)
	return os.exists('${db.path.path}/${name}')
}

pub fn (mut db ContextDB) db_delete(name_ string) ! {
	name := texttools.name_fix(name_)
	mut datafile := db.path.dir_get(name) or { return }
	datafile.delete()!
}

pub fn (mut db ContextDB) db_keys() ![]string {
	mut r := db.path.list(recursive: false, dirs_only: true)!
	mut res := []string{}
	for item in r.paths {
		res << item.name()
	}
	return res
}

pub fn (mut db ContextDB) db_prefix(prefix string) ![]string {
	mut res := []string{}
	for item in db.db_keys()! {
		// println(" ---- $item ($prefix)")
		if item.trim_space().starts_with(prefix) {
			// println("888")
			res << item
		}
	}
	return res
}

// delete all data in the contextdb (be careful)
pub fn (mut db ContextDB) destroy() ! {
	db.path.delete()!
}
