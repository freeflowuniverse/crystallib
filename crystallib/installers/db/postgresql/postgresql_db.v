
module postgresql

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import db.pg

pub fn (mut server Postgresql) path_config() !pathlib.Path {
	return pathlib.get_dir(path: '${server.path}/config', create: true)!
}	

pub fn (mut server Postgresql) path_data() !pathlib.Path {
	return pathlib.get_dir(path: '${server.path}/data', create: true)!
}	

pub fn (mut server Postgresql) path_export() !pathlib.Path {
	return pathlib.get_dir(path: '${server.path}/exports', create: true)!
}	

pub fn (mut server Postgresql) db() !pg.DB {
	mut db := pg.connect(
		host: 'localhost'
		user: 'root'
		password: server.passwd
		dbname: 'postgres'
	)!
	return db
}	

pub fn (mut server Postgresql) check() ! {
	mut db := server.db()!
	db.exec('SELECT version();') or {
        return error("postgresql could not do select version")
	}    
}

pub fn (mut server Postgresql) db_exists(name_ string) !bool {

	mut db := server.db()!
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

pub fn (mut server Postgresql) db_create(name_ string) ! {
	name := texttools.name_fix(name_)
	server.check()!
	mut db := server.db()!
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

pub fn (mut server Postgresql) db_delete(name_ string) ! {
	name := texttools.name_fix(name_)
	server.check()!
	mut db := server.db()!
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
