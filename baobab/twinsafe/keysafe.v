module twinsafe

import freeflowuniverse.crystallib.pathlib
// import freeflowuniverse.crystallib.mnemonic // buggy for now
import db.sqlite

pub struct KeysSafe {
pub mut:
	mytwins    map[string]MyTwin // is like a cache for what is in the sqlitedb
	secret     string // secret to encrypt local file
	db         sqlite.DB
	othertwins map[string]OtherTwin // is like a cache for what is in the sqlitedb
	myconfigs  map[string]MyConfig
}

[params]
pub struct KeysSafeNewArgs {
pub mut:
	path   string // location where sqlite db will be which holds the keys
	secret string // secret to encrypt local file
}

pub fn new(args_ KeysSafeNewArgs) !KeysSafe {
	mut args := args_
	if args.path.len == 0 {
		args.path = '~/.twin'
	}
	pathlib.get_dir(args.path, true)!
	mut db := sqlite.connect('${args.path}/keysafe.db')!
	mut safe := KeysSafe{
		db: db
		secret: args.secret
	}

	return safe
}

pub fn (mut safe KeysSafe) save() ! {
	// walk over mem, make sure all info from mem is also in sqlitedb
	for _, twin in safe.mytwins {
		safe.upsert_mytwin(twin)!
	}
	for _, other_twin in safe.othertwins {
		safe.upsert_othertwin(other_twin)!
	}
	for _, config in safe.myconfigs {
		safe.upsert_config(config)!
	}
}

fn (mut safe KeysSafe) upsert_mytwin(twin MyTwin) ! {
	twins := sql safe.db {
		select from MyTwin where id == twin.id
	}!
	if twins.len > 0 {
		// twin already exists in the data base so we update
		sql safe.db {
			update MyTwin set name = twin.name, description = twin.description, privatekey = twin.privatekey
			where id == twins[0].id
		}!
		return
	}
	sql safe.db {
		insert twin into MyTwin
	}!
}

fn (mut safe KeysSafe) upsert_othertwin(otwin OtherTwin) ! {
	otwins := sql safe.db {
		select from OtherTwin where id == otwin.id
	}!
	if otwins.len > 0 {
		sql safe.db {
			update OtherTwin set name = otwin.name, description = otwin.description, conn_type = otwin.conn_type,
			addr = otwin.addr, state = otwin.state where id == otwins[0].id
		}!
		return
	}
	sql safe.db {
		insert otwin into OtherTwin
	}!
}

fn (mut safe KeysSafe) upsert_config(config MyConfig) ! {
	configs := sql safe.db {
		select from MyConfig where id == config.id
	}!
	if configs.len > 0 {
		sql safe.db {
			update MyConfig set name = config.name, description = config.description, config = config.config
			where id == configs[0].id
		}!
		return
	}
	sql safe.db {
		insert config into MyConfig
	}!
}

pub fn (mut safe KeysSafe) loadall() ! {
	// walk over sqlitedb, load all in mem
	mytwins := safe.load_mytwins()!
	for twin in mytwins {
		safe.mytwins[twin.name] = twin
	}
	other_twins := safe.load_other_twins()!
	for otwin in other_twins {
		safe.othertwins[otwin.name] = otwin
	}
	configs := safe.load_myconfig()!
	for config in configs {
		safe.myconfigs[config.name] = config
	}
}

fn (mut safe KeysSafe) load_mytwins() ![]MyTwin {
	twins := sql safe.db {
		select from MyTwin
	}!
	return twins
}

fn (mut safe KeysSafe) load_other_twins() ![]OtherTwin {
	other_twins := sql safe.db {
		select from OtherTwin
	}!
	return other_twins
}

fn (mut safe KeysSafe) load_myconfig() ![]MyConfig {
	configs := sql safe.db {
		select from MyConfig
	}!
	return configs
}
