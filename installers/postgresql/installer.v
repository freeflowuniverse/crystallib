module postgresql


import freeflowuniverse.crystallib.tmux
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.installers.docker
import db.pg
import os

// const templatedir = os.dir(@FILE) + '/templates'

[params]
pub struct InstallArgs {
pub mut:
	reset bool
	path string = "/data/postgresql"
	passwd string [required]
	host_remove bool =true //make sure is gone from the host
}

pub struct Postgresql{
pub mut:
	path_config pathlib.Path
	path_data pathlib.Path
	path_export pathlib.Path
	passwd string
}

//run postgresql as docker compose
pub fn new(args_ InstallArgs) !Postgresql {

	mut args:=args_

	if args.path==""{
		args.path="/data/postgresql"
	}

	if args.host_remove{
		host_remove()!
	}

	if args.reset{
		mut t := tmux.new()!
		t.window_delete(name: 'postgresql')!
		osal.dir_delete(args.path)!
		osal.done_delete('postgres_started')!		
	}

	mut s:=Postgresql{
		path_config:pathlib.get_dir("${args.path}/config",true)!
		path_data:pathlib.get_dir("${args.path}/data",true)!
		path_export:pathlib.get_dir("${args.path}/exports",true)!
		passwd:args.passwd
	}

	return s
}

//run postgresql as docker compose
pub fn (mut s Postgresql) start() ! {

	if !osal.done_exists('postgres_started') {	

		docker.install()! //make sure docker is installed and working properly

		t1:= $tmpl('templates/compose.yaml')
		mut p1:=s.path_config.file_get_new("compose.yaml")!
		p1.write(t1)!	

		t2:= $tmpl('templates/pg_hba.conf')
		mut p2:=s.path_config.file_get_new("pg_hba.conf")!
		p2.write(t2)!	

		mut t3:= $tmpl('templates/postgresql.conf')
		t3=t3.replace("@@","$") //to fix templating issues
		mut p3:=s.path_config.file_get_new("postgresql.conf")!
		p3.write(t3)!		

		s.stop()!

		mut t := tmux.new()!
		c:='
		cd ${s.path_config.path}
		docker compose up	
		echo "DOCKER COMPOSE ENDED, EXIT TO BASH"
		/bin/bash 
		'
		mut w:=t.window_new(name: 'postgresql', cmd: c, reset:true)!
		w.output_wait("database system is ready to accept connections",120)!

		osal.package_install("libpq-dev,postgresql-client-16")!

		pg.connect(host: 'localhost', user: 'root', password:s.passwd, dbname:'postgres')!

		osal.done_set('postgres_started', 'OK')!
	}


}

pub fn  (mut s Postgresql) stop() ! {
	osal.done_delete('postgres_started')!
	c:='
	// cd ${s.path_config.path}
	// docker compose down
	// '
	// osal.exec(cmd:c)!
	mut t := tmux.new()!
	t.window_delete(name: 'postgresql')!
}

pub fn  (mut s Postgresql) restart() ! {
	s.stop()!
	s.start()!

}

//check health, return true if ok
pub fn  (mut s Postgresql) check() bool {

	db := pg.connect(host: 'localhost', user: 'root', password:s.passwd, dbname:'postgres') or {return false}
	return true
}

//check health, restart if needed
pub fn  (mut s Postgresql) check_restart() ! {
	r:=s.check()
	if r==false{
		s.restart()!
	}
}


pub fn  (mut s Postgresql) db_create(name_ string) ! {
	name:=texttools.name_fix(name_)
	s.check_restart()!
	db := pg.connect(host: 'localhost', user: 'root', password:s.passwd, dbname:'postgres')!

	r:=db.exec("SELECT 1 FROM pg_database WHERE datname='${name}';")!
	if r.len==1{
		return
	}
	db.exec("CREATE DATABASE ${name};")!
	r2:=db.exec("SELECT 1 FROM pg_database WHERE datname='${name}';")!
	if r2.len!=1{
		return error("Could not create db: ${name}, could not find in DB.")
	}

}



//remove postgresql from the system
pub fn host_remove() ! {
	if !osal.done_exists('postgres_remove') {

		c:='
		#!/bin/bash

		set +e

		# Stop the PostgreSQL service
		sudo systemctl stop postgresql

		# Purge PostgreSQL packages
		sudo apt-get purge -y postgresql* pgdg-keyring

		# Remove all data and configurations
		sudo rm -rf /etc/postgresql/
		sudo rm -rf /etc/postgresql-common/
		sudo rm -rf /var/lib/postgresql/
		sudo userdel -r postgres
		sudo groupdel postgres

		# Remove systemd service files
		sudo rm -f /etc/systemd/system/multi-user.target.wants/postgresql
		sudo rm -f /lib/systemd/system/postgresql.service
		sudo rm -f /lib/systemd/system/postgresql@.service

		# Reload systemd configurations and reset failed systemd entries
		sudo systemctl daemon-reload
		sudo systemctl reset-failed

		echo "PostgreSQL has been removed completely"

		'
		osal.exec(cmd:c)!		
		osal.done_set('postgres_remove', 'OK')!
	}


}

