module postgresql

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.zinit 
import freeflowuniverse.crystallib.data.fskvs
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import json
import rand
import db.pg


[params]
pub struct Config {
pub mut:
	name        string = 'default'
	path        string = '/data/postgresql'
	passwd      string
}


pub struct Server {
pub mut:
	name string
	config Config
	process ?zinit.ZProcess
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
pub fn new(args_ Config) !Server {
	install()! //make sure it has been build & ready to be used
	mut args := args_
	if args.passwd == ""{
		args.passwd = rand.string(12)
	}
	if args.path == '' {
		args.path = '/data/postgresql'
	}
	args.name=texttools.name_fix(args.name)
	key:="postgres_config_${args.name}"
	mut kvs:=fskvs.new(name:"config")!
	if !kvs.exists(key){
		data:=json.encode(args)
		kvs.set(key,data)!		
	}
	return get(args.name)!
}



pub fn get(name_ string) !Server {
	println(" - get postgresql server $name_")
	name:=texttools.name_fix(name_)
	key:="postgres_config_${name}"
	mut kvs:=fskvs.new(name:"config")!
	if kvs.exists(key){
		data:=kvs.get(key)!	
		args:=json.decode(Config,data)!

		mut server := Server{
			name:name
			config:args
			path_config: pathlib.get_dir(path: '${args.path}/config', create: true)!
			path_data: pathlib.get_dir(path: '${args.path}/data', create: true)!
			path_export: pathlib.get_dir(path: '${args.path}/exports', create: true)!
		}
		mut z := zinit.new()!
		processname:='postgres_${name}'
		if z.process_exists(processname){
			server.process=z.process_get(processname)!
		}
		// println(" - server get ok")
		server.start()!
		return server	
	}
	return error ("can't find server postgres with name $name")
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
	mut process := server.process or {return .unknown}
	return process.status() or {return .unknown}
}


// run postgresql as docker compose
pub fn (mut server Server) start() ! {

	if server.ok(){
		return 
	}

	println (" - start postgresql: ${server.name}")

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
	mut z := zinit.new()!
	processname:='postgres_${server.name}'
	mut p := z.process_new(
		name: processname
		cmd: cmd
	)!

	p.output_wait("database system is ready to accept connections",120)!		

	server.check()!

	println(" - postgres login check worked")

}

pub fn (mut server Server) restart() ! {
	server.stop()!
	server.start()!
}

pub fn (mut server Server) stop() !{
	print_backtrace()
	println (" - stop postgresql: ${server.name}")
	mut process := server.process or {return}
	return process.stop()
}

// check health, return true if ok
pub fn (mut server Server) check() ! {
	db := pg.connect(host: 'localhost', user: 'root', password: server.config.passwd, dbname: 'postgres') or {
		return error("cant connect to postgresql server:\n$server")
	}
	db.exec("SELECT version();") or { return error("can\t select version from database.\n$server")}
}

// check health, return true if ok
pub fn (mut server Server) ok() bool {
	server.check() or {
		return false
	}
	return true
}

pub fn (mut server Server) db_create(name_ string) ! {
	name := texttools.name_fix(name_)
	server.check()!
	db := pg.connect(host: 'localhost', user: 'root', password: server.config.passwd, dbname: 'postgres')!

	r := db.exec("SELECT 1 FROM pg_database WHERE datname='${name}';")!
	if r.len == 1 {
		return
	}
	db.exec('CREATE DATABASE ${name};')!
	r2 := db.exec("SELECT 1 FROM pg_database WHERE datname='${name}';")!
	if r2.len != 1 {
		return error('Could not create db: ${name}, could not find in DB.')
	}
}


//remove all data
pub fn (mut server Server) destroy() ! {
	server.stop()!
	server.path_data.delete()!
	server.path_export.delete()!
	//TODO: need to do more
}
