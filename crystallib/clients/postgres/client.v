module postgres

import db.pg
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.fskvs
import freeflowuniverse.crystallib.data.actionparser
import json
// import time
import freeflowuniverse.crystallib.ui
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct PostgresClientConfig {
pub mut:
	name     string = 'default'
	user     string = 'root'
	port     int    = 5432
	host     string = 'localhost'
	password string
	dbname   string = 'postgres'
	script3  string
	reset    bool
}

pub struct PostgresClient {
pub mut:
	name   string               @[required]
	config PostgresClientConfig
	db     pg.DB
}

pub fn list() ![]string {
	prefix := 'postgrescl_config'
	mut kvs := fskvs.new(name: 'config')!
	mut res := []string{}
	for x in kvs.prefix(prefix)! {
		res << x[prefix.len + 1..]
	}
	// println(res)
	return res
}

@[params]
pub struct PrintArgs {
pub mut:
	name string
}

pub fn configprint(args PrintArgs) ! {
	mut kvs := fskvs.new(name: 'config')!
	if args.name.len > 0 {
		key := 'postgrescl_config_${args.name}'
		// println(" === $key")
		if kvs.exists(key) {
			data := kvs.get(key)!
			c := json.decode(PostgresClientConfig, data)!
			println(c)
			println('')
		} else {
			return error("Can't find postgresql DB connection with name: ${args.name}")
		}
	} else {
		for item in list()! {
			// println(" ==== $item")
			configprint(name: item)!
		}
	}
}

pub fn get(args_ PostgresClientConfig) !PostgresClient {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	if args.name == '' {
		args.name = 'default'
	}
	args = configure(args)!
	// println(args)
	mut db := pg.connect(
		host: args.host
		user: args.user
		port: args.port
		password: args.password
		dbname: args.dbname
	)!
	// println(postgres_client)
	return PostgresClient{
		name: args.name
		db: db
		config: args
	}
}

struct LocalConfig {
	name   string
	path   string
	passwd string
}

// is there a local server can we get the passwd
fn local_server_config_get(name_ string) !LocalConfig {
	name := texttools.name_fix(name_)
	key := 'postgres_config_${name}'
	mut kvs := fskvs.new(name: 'config')!
	if kvs.exists(key) {
		data := kvs.get(key)!
		args := json.decode(LocalConfig, data)!
		return args
	}
	return LocalConfig{}
}

pub fn configure(args_ PostgresClientConfig) !PostgresClientConfig {
	mut args := args_
	args.name = texttools.name_fix(args.name)

	if args.script3.len > 0 {
		// means 3script used to configure this client
		mut ap := actionparser.parse_collection(text: args.script3)!
		for action in ap.actions {
			if action.actor == 'postgres_client' && action.name == 'define' {
				args.name = action.params.get_default('name', 'default')!
			}
			panic('implement')
		}
	}

	key := 'postgrescl_config_${args.name}'
	mut kvs := fskvs.new(name: 'config')!
	if args.reset || !kvs.exists(key) {
		// check if there is a local server configured
		lconfig := local_server_config_get(args.name)!
		if lconfig.passwd.len > 0 {
			args.password = lconfig.passwd
		}
		data := json.encode_pretty(args)
		kvs.set(key, data)!
	}
	data := kvs.get(key)!
	mut client_config := json.decode(PostgresClientConfig, data)!
	return client_config
}

pub fn configure_interactive(args_ PostgresClientConfig) ! {
	mut args := configure(args_)!
	mut myui := ui.new()!

	console.clear()
	println('\n## Configure Postgres Client')
	println('============================\n\n')

	args.name = myui.ask_question(
		question: 'name for postgres client'
		default: args.name
	)!

	args.user = myui.ask_question(
		question: 'user'
		minlen: 3
		default: args.user
	)!

	args.password = myui.ask_question(
		question: 'password'
		minlen: 3
		default: args.password
	)!

	args.dbname = myui.ask_question(
		question: 'dbname'
		minlen: 3
		default: args.dbname
	)!

	args.host = myui.ask_question(
		question: 'host'
		minlen: 3
		default: args.host
	)!
	mut port := myui.ask_question(
		question: 'port'
		default: '${args.port}'
	)!
	args.port = port.int()

	println(args)
	configure(args)!
}
