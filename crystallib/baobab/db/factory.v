module db

import db.sqlite
import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.core.texttools

__global (
	dbs      shared map[string]DB
	dbs_init shared map[string]bool
)

[heap]
pub struct DB {
pub mut:
	cid      smartid.CID
	sqlitedb sqlite.DB
}

[params]
pub struct DBArgs {
pub mut:
	cid smartid.CID
}

pub fn new(args_ DBArgs) ! {
	mut args := args_
	name := args.cid.str()

	mut heropath := pathlib.get_dir(path: '~/hero/db', create: true)!

	mut sqlitedb := sqlite.connect('${heropath.path}/${name}.db')!

	mut db := DB{
		cid: args.cid
		sqlitedb: sqlitedb
	}

	tables_create_core(mut db)!

	lock dbs {
		dbs[name] = &db
	}
}

[params]
pub struct DBSetArgs {
pub mut:
	gid          smartid.GID
	objtype      string // unique type name for obj class
	index_int    map[string]int
	index_string map[string]string
	data         []u8
}

pub fn set(args_ DBSetArgs) ! {
	mut args := args_
	lock dbs {
		mut mydb := dbs[args.gid.cid.str()] or { return error('cannot find db with cid: ${args.gid.cid}') }
		table_set(mut mydb, mut args)!
	}
}

[params]
pub struct DBTableCreateArgs {
pub mut:
	cid          smartid.CID
	objtype      string // unique type name for obj class
	index_int    []string
	index_string []string
}

// create required tables for requested object
pub fn create(args_ DBTableCreateArgs) ! {
	mut args := args_
	mut tablename:=""
	lock dbs {
		mydb := dbs[args.cid.str()] or { return error('cannot find db with cid: ${args.cid}') }
		tablename = table_name(mydb, args.objtype)
	}

	lock dbs_init {
		if tablename in dbs_init {
			return
		}
	}
	lock dbs {
		println('create table for ${args_}')
		mut mydb2 := dbs[args.cid.str()] or { return error('cannot find db with cid: ${args.cid}') }
		table_create(mut mydb2, mut args)!
	}
	lock dbs_init {
		dbs_init[tablename] = true
	}
}


