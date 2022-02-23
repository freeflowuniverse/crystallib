module postgresapp

import os
import despiegk.crystallib.builder
import despiegk.crystallib.appsbox

[heap]
pub struct PostgresApp {
pub mut:
	name 			string 
	postgres_passwd string
	instance 		appsbox.AppInstance
}

pub struct PostgresAppArgs{
	name 				string = "default"
	port 				int = 5432
	unixsocketpath		string = ""
	postgres_passwd 	string = "oursecret" //should be changed by user when init
}

//get a postgres app based on port & name, are optional both
// default is name:default port:5432
pub fn get(args PostgresAppArgs) appsbox.App{
	mut factory := appsbox.get()
	for item in factory.apps{
		if item.instance.tcpports == [args.port] && item.instance.name == args.name {
			return item
		}
	}
	mut i := appsbox.AppInstance{
			name:args.name
			tcpports:[args.port]
		}
	mut myapp := PostgresApp{
			name:args.name,
			instance:i
			postgres_passwd: args.postgres_passwd
		}
	factory.apps << myapp
	return myapp
}

pub fn (mut myapp PostgresApp) start() ?{
	mut factory := appsbox.get()
	myapp.install(false)?
	mut bin_path := appsbox.get().bin_path
	mut n := builder.node_local()?

	mut tcpport := myapp.instance.tcpports[0]
	postgres_path := "${factory.apps_path}/postgres"

	//set a start command for postgresql
	cmd := "${postgres_path}/bin/postgres_start"
	n.exec(cmd:cmd, reset:true, description:"start postgres",stdout:true)?	
	alive := myapp.check()?
	if ! alive{
		return error("Could not start postgres.")
	}
}

pub fn (mut myapp PostgresApp) stop() ?{
	mut bin_path := appsbox.get().bin_path
	mut n := builder.node_local()?
	mut tcpport := myapp.instance.tcpports[0]
	//TODO, needs to be implemented, now copy from redis
	cmd := "${bin_path}/postgres-cli -p $tcpport SHUTDOWN"
	n.exec(cmd:cmd, reset:true, description:"stop postgres",stdout:true)?	
}

pub fn (mut myapp PostgresApp) install(reset bool)?{
	mut factory := appsbox.get()

	mut n := builder.node_local()?
	myapp.instance.bins = ["postgres-server","postgres-cli"]

	//check app is installed, if yes don't need to do anything
	if reset || ! myapp.instance.exists(){
		myapp.build()?
	}

	tcpport := myapp.instance.tcpports[0]
	postgres_path := "${factory.apps_path}/postgres"
	bin_path := "${postgres_path}/bin"

	if ! os.exists("${postgres_path}/var"){
		//means we need to init a DB
		cmd := "$bin_path/initdb -D '${postgres_path}/var'"
		n.executor.exec_silent(cmd)?
	}

	//need to set  DYLD_LIBRARY_PATH to make sure if we build on other machine with different dir it still works
	//other way: ./pg_ctl -D /tmp/postgres2 -l logfile start
	cmd_start := "export DYLD_LIBRARY_PATH=${postgres_path}/lib;${bin_path}/postgres -D '${postgres_path}/var'"
	n.executor.file_write("${bin_path}/postgres_start",cmd_start)?	

	mut postgres_conf := $tmpl("postgresql.conf")	
	n.executor.file_write("${postgres_path}/var/postgresql.conf",postgres_conf)?
	n.executor.exec_silent("chmod 770 ${var_path}/postgres_start")?

	//TODO: now need to set root user and passwd, make sure security is all tight
	//SEE postgres_passwd
}

pub fn (mut myapp PostgresApp) build()?{
	mut factory := appsbox.get()
	mut n := builder.node_local()?
	tcpport := myapp.instance.tcpports[0]
	postgres_path := "${factory.apps_path}/postgres"
	mut cmd := $tmpl("postgres_build.sh")
	mut tmpdir:="/tmp/postgres"
	n.exec(cmd:cmd, reset:true, description:"install postgres ; echo ok",stdout:true, tmpdir:tmpdir)?
}

//create database, give admin user (postgres) all rights
pub fn (mut myapp PostgresApp) create_db(db_name string)?{
	//TODO:...
}

//export database to path (use compression)
pub fn (mut myapp PostgresApp) export_db(db_name string, path string)?{
	//TODO:...
}

//import db, drop before import
pub fn (mut myapp PostgresApp) import_db(db_name string, path string)?{
	//TODO:...
}


//checks postgresql is answering
pub fn (mut myapp PostgresApp) check()?bool{
	//TODO:
	// mut postgrescl := ...
	// result := postgrescl.ping()?	
	// if result=="PONG"{
	// 	return true
	// }
	// panic(result)
	return false
}

pub fn (mut myapp PostgresApp) client()?{
	// mut tcpport := myapp.instance.tcpports[0]
	// return postgresclient.get("/tmp/postgres_${tcpport}.sock")
}