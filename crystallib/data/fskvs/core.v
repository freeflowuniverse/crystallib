module fskvs

import freeflowuniverse.crystallib.core.texttools

@[params]
pub struct KVSCoreGetArgs {
pub mut:
	dbname string = 'core'
}

// will open DB in 'core' contextdb which is always non encrypted, non interactive
pub fn db_core(args_ KVSCoreGetArgs) !DB {
	mut args := args_
	args.dbname = texttools.name_fix(args.dbname)

	if !contextdb_exists('default') {
		contextdb_configure()!
	}

	mut contextdb := contextdb_get(interactive: false)!

	if !contextdb.db_exists(args.dbname) {
		contextdb.db_configure(dbname: args.dbname, encrypted: false)!
	}

	mut db := contextdb.db_get(dbname: args.dbname)!
	return db
}

pub fn dbcontext_init_default() ! {
	contextdb_configure(encrypted: true)!

	mut contextdb := contextdb_get(interactive: true)!

	if !contextdb.db_exists('default') {
		contextdb.db_configure(dbname: 'default', encrypted: true)!
	}

	contextdb.db_get()! // should ask encryption passwd if not set
}
