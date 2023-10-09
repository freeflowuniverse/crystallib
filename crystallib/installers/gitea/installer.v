module gitea

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.tmux
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.installers.postgresql
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
	smpt_port         int    = 587
	smtp_passwd       string
	appname           string [required]
	domain            string [required]
}

pub struct Gitea {
pub mut:
	path_config pathlib.Path
	args        InstallArgs
}

// run gitea as docker compose
pub fn new(args_ InstallArgs) !Gitea {
	mut args := args_

	if args.postgresql_passwd == '' {
		args.postgresql_passwd = args.passwd
	}

	if args.reset {
		mut t := tmux.new()!
		t.window_delete(name: 'gitea')!
		osal.dir_delete(args.path)!
		osal.done_delete('gitea_started')!
	}

	install(args.reset)!

	mut db := postgresql.new(
		passwd: args.postgresql_passwd
		path: args.postgresql_path
		reset: args.postgresql_reset
	)!
	db.db_create('gitea')!

	mut s := Gitea{
		path_config: pathlib.get_dir('${args.path}/config', true)!
		args: args
	}

	return s
}

// install gitea will return true if it was already installed
pub fn install(reset bool) ! {
	// make sure we install base on the node
	base.install()!

	if reset == false && osal.done_exists('install_gitea') {
		return
	}

	// install gitea if it was already done will return true
	println(' - package_install install gitea')

	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}
	mut dest := osal.download(
		url: 'https://github.com/go-gitea/gitea/releases/download/v1.20.4/gitea-1.20.4-linux-amd64.xz'
		minsize_kb: 40000
		reset: true
		expand_file: '/tmp/download/gitea'
	)!

	// TODO: does not download well

	mut giteafile := pathlib.get_file('/tmp/download/gitea', false)! // file in the dest
	println(giteafile)
	giteafile.copy('/usr/local/bin')!
	giteafile.chmod(0o770)! // includes read & write & execute

	osal.done_set('install_gitea', 'OK')!
	return
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
