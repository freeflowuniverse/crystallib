module postgresql

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.startupmanager
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import db.pg
import os

@[params]
pub struct Config {
pub mut:
	name   string = 'default'
	path   string // /data/postgresql/${name} for linux /hero/var/redis/${args.name} for osx
	passwd string @[required]
}

pub struct Server {
pub mut:
	name        string
	config      Config
	path_config pathlib.Path
	path_data   pathlib.Path
	path_export pathlib.Path
}

// get the postgres server
//```js
// name        string = 'default'
// path        string = '/data/postgresql'
// passwd      string
//```
// if name exists already in the config DB, it will load for that name
pub fn start(args_ Config) !Server {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	console.print_header('start postgresql server ${name}')
	requirements()! // make sure requirements are done
	if args.path == '' {
		if osal.is_linux() {
			args.path = '/data/postgresql/${args.name}'
		} else {
			args.path = '${os.home_dir()}/hero/var/redis/${args.name}'
		}
	}
	mut server := Server{
		name: args.name
		config: args
		path_config: pathlib.get_dir(path: '${args.path}/config', create: true)!
		path_data: pathlib.get_dir(path: '${args.path}/data', create: true)!
		path_export: pathlib.get_dir(path: '${args.path}/exports', create: true)!
	}

	mut z := zinit.new()!
	processname := 'postgres_${name}'
	if z.process_exists(processname) {
		server.process = z.process_get(processname)!
	}
	// println(" - server get ok")
	server.start()!
	return server
}

// return status
// ```
// pub enum ZProcessStatus {
// 	unknown
// 	init
// 	ok
// 	error
// 	blocked
// 	spawned
// }
// ```
pub fn (mut server Server) status() zinit.ZProcessStatus {
	mut process := server.process or { return .unknown }
	return process.status() or { return .unknown }
}

// run postgresql as docker compose
pub fn (mut server Server) start() ! {
	if server.ok() {
		return
	}

	console.print_header('start postgresql: ${server.name}')

	t1 := $tmpl('templates/compose.yaml')
	mut p1 := server.path_config.file_get_new('compose.yaml')!
	p1.write(t1)!

	t2 := $tmpl('templates/pg_hba.conf')
	mut p2 := server.path_config.file_get_new('pg_hba.conf')!
	p2.write(t2)!

	mut t3 := $tmpl('templates/postgresql.conf')
	t3 = t3.replace('@@', '$') // to fix templating issues
	mut p3 := server.path_config.file_get_new('postgresql.conf')!
	p3.write(t3)!

	cmd := '
	cd ${server.path_config.path}
	docker compose up	
	echo "DOCKER COMPOSE ENDED, EXIT TO BASH"
	'
	mut sm := startupmanager.get()!
	sm.start(
		name: 'postgres_${server.name}'
		cmd: cmd
	)!

	p.output_wait('database system is ready to accept connections', 120)!

	server.check()!

	console.print_header('postgres login check worked')
}

pub fn (mut server Server) restart() ! {
	server.stop()!
	server.start()!
}

pub fn (mut server Server) stop() ! {
	print_backtrace()
	console.print_header('stop postgresql: ${server.name}')
	mut process := server.process or { return }
	return process.stop()
}

// check health, return true if ok
pub fn (mut server Server) check() ! {
	db := pg.connect(
		host: 'localhost'
		user: 'root'
		password: server.config.passwd
		dbname: 'postgres'
	) or { return error('cant connect to postgresql server:\n${server}') }
	db.exec('SELECT version();') or {
		return error('can\t select version from database.\n${server}')
	}
}

// check health, return true if ok
pub fn (mut server Server) ok() bool {
	server.check() or { return false }
	return true
}

pub fn (mut server Server) db_exists(name_ string) !bool {
	db := pg.connect(
		host: 'localhost'
		user: 'root'
		password: server.config.passwd
		dbname: 'postgres'
	)!

	// SELECT datname FROM pg_database WHERE datname='gitea';
	r := db.exec("SELECT datname FROM pg_database WHERE datname='${name_}';")!
	if r.len == 1 {
		console.print_header('db exists: ${name_}')
		return true
	}
	if r.len > 1 {
		return error('should not have more than 1 db with name ${name_}')
	}
	return false
}

pub fn (mut server Server) db_create(name_ string) ! {
	name := texttools.name_fix(name_)
	server.check()!
	db := pg.connect(
		host: 'localhost'
		user: 'root'
		password: server.config.passwd
		dbname: 'postgres'
	)!
	db_exists := server.db_exists(name_)!
	if !db_exists {
		console.print_header('db create: ${name_}')
		db.exec('CREATE DATABASE ${name};')!
	}
	db_exists2 := server.db_exists(name_)!
	if !db_exists2 {
		return error('Could not create db: ${name_}, could not find in DB.')
	}
}

pub fn (mut server Server) db_delete(name_ string) ! {
	name := texttools.name_fix(name_)
	server.check()!
	db := pg.connect(
		host: 'localhost'
		user: 'root'
		password: server.config.passwd
		dbname: 'postgres'
	)!
	db_exists := server.db_exists(name_)!
	if db_exists {
		console.print_header('db delete: ${name_}')
		db.exec('DROP DATABASE ${name};')!
	}
	db_exists2 := server.db_exists(name_)!
	if db_exists2 {
		return error('Could not delete db: ${name_}, could not find in DB.')
	}
}

// remove all data
pub fn (mut server Server) destroy() ! {
	server.stop()!
	server.path_data.delete()!
	server.path_export.delete()!
	// TODO: need to do more
}
