module postgres

import freeflowuniverse.crystallib.core.play
import db.pg
import freeflowuniverse.crystallib.core.texttools

pub struct PostgresClient {
	play.Base
pub mut:
	config Config
	db     pg.DB
}

@[params]
pub struct ClientArgs {
pub mut:
	instance string        @[required]
	playargs ?play.PlayArgs
}

pub fn get(clientargs ClientArgs) !PostgresClient {
	mut plargs:=clientargs.playargs or {play.PlayArgs{}}	
	mut cfg := configurator(clientargs.instance, plargs)!
	mut args := cfg.get()!

	args.instance = texttools.name_fix(args.instance)
	if args.instance == '' {
		args.instance = 'default'
	}
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
		instance: args.instance
		db: db
		config: args
	}
}

struct LocalConfig {
	name   string
	path   string
	passwd string
}

// // is there a local server can we get the passwd
// fn local_server_config_get(name_ string) !LocalConfig {
// 	name := texttools.name_fix(name_)
// 	key := 'postgres_config_${name}'
// 	mut kvs := fskvs.new(name: 'config')!
// 	if kvs.exists(key) {
// 		data := kvs.get(key)!
// 		args := json.decode(LocalConfig, data)!
// 		return args
// 	}
// 	return LocalConfig{}
// }
