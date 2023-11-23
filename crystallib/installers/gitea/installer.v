module gitea

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal.tmux
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.installers.postgresql
import json
import os

[params]
pub struct InstallArgs {
pub mut:
	reset             bool
	path              string = '/data/gitea'
	passwd            string [required]
	postgresql_reset  bool
	postgresql_path   string
	postgresql_passwd string // for now all on default port
	mail_from         string = 'git@meet.tf'
	smtp_addr         string = 'smtp-relay.brevo.com'
	smtp_login	      string [required]
	smpt_port         int    = 587
	smtp_passwd       string
	name           	  string = "main"
	domain			  string [required]
	jwt_secret        string
	lfs_jwt_secret    string 
	internal_token    string
	secret_key        string
}

[params]
pub struct GetArgs {
pub mut:
	name           string = "main"
}

pub struct Gitea {
pub mut:
	path_config pathlib.Path
	args        InstallArgs
}

fn key_get(name string) string {
	return "gitea_install_args_${name}"
}

pub fn new(getargs GetArgs) !Gitea {
	data:=osal.done_get(key_get(getargs.name)) or { 
		return error("can't get gitea because install has not happened before. Can't find the installer data.")
	}
	mut args:=json.decode(InstallArgs,data)!

	mut s := Gitea{
		path_config: pathlib.get_dir(path: '${args.path}/config', create: true)!
		args: args
	}
	return s
}


// install gitea will return true if it was already installed
pub fn install(args_ InstallArgs) !Gitea {
	mut args := args_

	if args.reset == false && osal.done_exists(key_get(args.name)) {
		return new(name:args_.name)
	}

	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}

	// make sure we install base on the node
	base.install()!


	mut db := postgresql.new(
		passwd: args.postgresql_passwd
		path: args.postgresql_path
		reset: args.postgresql_reset
	)!
	db.start()!
	db.db_create('gitea_${args.name}')!
		

	version:="1.21.0"
	url:='https://github.com/go-gitea/gitea/releases/download/v${version}/gitea-${version}-linux-amd64.xz'
	println (" download ${url}")
	mut dest := osal.download(
		url: url
		minsize_kb: 40000
		reset: true
		expand_file: '/tmp/download/gitea'
	)!

	binpath:=pathlib.get_file(path:"/tmp/download/gitea",create:false)!
	osal.bin_copy(
		cmdname: 'gitea'
		source: binpath.path
	)!	

	if args.postgresql_passwd == '' {
		args.postgresql_passwd = args.passwd
	}

	// jwt_secret        string
	// lfs_jwt_secret    string 
	// internal_token    string
	// secret_key        string

	if args.jwt_secret == '' {
		r:=os.execute_or_panic("gitea generate secret JWT_SECRET")
		args.jwt_secret = r.output.trim_space()
	}
	if args.lfs_jwt_secret == '' {
		r:=os.execute_or_panic("gitea generate secret LFS_JWT_SECRET")
		args.lfs_jwt_secret = r.output.trim_space()
	}
	if args.internal_token == '' {
		r:=os.execute_or_panic("gitea generate secret INTERNAL_TOKEN")
		args.internal_token = r.output.trim_space()
	}
	if args.secret_key == '' {
		r:=os.execute_or_panic("gitea generate secret SECRET_KEY")
		args.secret_key = r.output.trim_space()
	}

	println(args)
	// install gitea if it was already done will return true
	println(' - package_install install gitea: $args.name')


	data:=json.encode(args)
	osal.done_set(key_get(args.name),data)!

	return new(name:args_.name)
}

// run Gitea as docker compose
pub fn (mut s Gitea) start() ! {
	if !osal.done_exists('gitea_started') {
		t1 := $tmpl('templates/app.ini')
		mut p1 := s.path_config.file_get_new('app.ini')!
		p1.write(t1)!

		s.stop()!

		mut t := tmux.new()!
		c := '
		cd ${s.path_config.path}
		//TODO
		echo "GITEA ENDED EXIT TO BASH"
		/bin/bash 
		'
		mut w := t.window_new(name: 'gitea', cmd: c, reset: true)!
		w.output_wait('oooooo', 120)!

		osal.done_set('gitea_started', 'OK')!
	}
}

pub fn (mut s Gitea) stop() ! {
	osal.done_delete('gitea_started')!
	mut t := tmux.new()!
	t.window_delete(name: 'gitea')!
}

pub fn (mut s Gitea) restart() ! {
	s.stop()!
	s.start()!
}

// check health, return true if ok
pub fn (mut s Gitea) check() bool {
	panic('implement')
	return true
}

// check health, restart if needed
pub fn (mut s Gitea) check_restart() ! {
	r := s.check()
	if r == false {
		s.restart()!
	}
}
