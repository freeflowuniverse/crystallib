module postgresql

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.sysadmin.startupmanager
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import db.pg
import os
import time

@[params]
pub struct Config {
pub mut:
	name   string = 'default'
	path   string // /data/postgresql/${name} for linux /hero/var/postgresql/${args.name} for osx
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
	console.print_header('start postgresql server ${args.name}')
	requirements()! // make sure requirements are done
	if args.path == '' {
		if osal.is_linux() {
			args.path = '/data/postgresql/${args.name}'
		} else {
			args.path = '${os.home_dir()}/hero/var/postgresql/${args.name}'
		}
	}
	mut server := Server{
		name: args.name
		config: args
		path_config: pathlib.get_dir(path: '${args.path}/config', create: true)!
		path_data: pathlib.get_dir(path: '${args.path}/data', create: true)!
		path_export: pathlib.get_dir(path: '${args.path}/exports', create: true)!
	}

	processname := 'postgres_${args.name}'

	mut manager := startupmanager.get()!
	if !manager.exists(processname) {
		server.start()!
	}
	// console.print_debug(" - server get ok")

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

	cmd := "bash -c \"
	cd ${server.path_config.path}
	docker compose up 
	\""
	mut sm := startupmanager.get()!
	sm.start(
		name: 'postgres_${server.name}'
		cmd: cmd
	)!

	// p.output_wait('database system is ready to accept connections', 120)!
	now := time.now()
	mut ready := false
	mut err_msg := ''
	for time.since(now) < time.second * 10 {
		server.check() or {
			console.print_header('preparing database...')
			err_msg = err.str()
			time.sleep(time.millisecond * 100)
			continue
		}

		ready = true
		break
	}

	if !ready {
		return error('failed to run database: ${err_msg}')
	}

	console.print_header('postgres login check worked')
}

pub fn (mut server Server) restart() ! {
	server.stop()!
	server.start()!
}

pub fn (mut server Server) stop() ! {
	console.print_header('stop postgresql: ${server.name}')

	mut sm := startupmanager.get()!
	sm.kill('postgres_${server.name}')!
}

// check health, return true if ok
pub fn (mut server Server) check() ! {
	db := pg.connect(
		host: 'localhost'
		user: 'root'
		password: server.config.passwd
		dbname: 'postgres'
	) or { return error('cant connect to postgresql server:\n${server} due to error: ${err}') }
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
