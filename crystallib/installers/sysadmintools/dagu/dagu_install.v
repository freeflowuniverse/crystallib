module dagu

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.screen
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.clients.httpconnection
import os
import time

@[params]
pub struct InstallArgs {
pub mut:
	reset   bool
	passwd  string
	secret  string
	title   string
	start   bool = true
	restart bool
}

pub fn install(args_ InstallArgs) ! {
	mut args := args_
	version := '1.12.9'

	res := os.execute('source ${osal.profile_path()} && dagu version')
	if res.exit_code == 0 {
		r := res.output.split_into_lines().filter(it.trim_space().len > 0)
		if r.len != 1 {
			return error("couldn't parse dagu version.\n${res.output}")
		}
		if texttools.version(version) > texttools.version(r[0]) {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset {
		console.print_header('install dagu')

		mut url := ''
		if osal.is_linux_arm() {
			url = 'https://github.com/dagu-dev/dagu/releases/download/v${version}/dagu_${version}_linux_arm64.tar.gz'
		} else if osal.is_linux_intel() {
			url = 'https://github.com/dagu-dev/dagu/releases/download/v${version}/dagu_${version}_linux_amd64.tar.gz'
		} else if osal.is_osx_arm() {
			url = 'https://github.com/dagu-dev/dagu/releases/download/v${version}/dagu_${version}_darwin_arm64.tar.gz'
		} else if osal.is_osx_intel() {
			url = 'https://github.com/dagu-dev/dagu/releases/download/v${version}/dagu_${version}_darwin_amd64.tar.gz'
		} else {
			return error('unsported platform')
		}

		mut dest := osal.download(
			url: url
			minsize_kb: 9000
			expand_dir: '/tmp/dagu'
		)!

		mut binpath := dest.file_get('dagu')!
		osal.cmd_add(
			cmdname: 'dagu'
			source: binpath.path
		)!
	}

	if args.restart {
		restart(args)!
		return
	}

	if args.start {
		start(args)!
	}
}

pub fn configure(args_ InstallArgs) ! {
	mut args := args_
	if args.title == '' {
		args.title = 'HERO'
	}
	mycode := $tmpl('templates/admin.yaml')

	mut path := pathlib.get_file(path: '${os.home_dir()}/.dagu/admin.yaml', create: true)!
	path.write(mycode)!
}

pub fn restart(args_ InstallArgs) ! {
	stop(args_)!
	start(args_)!
}

pub fn stop(args_ InstallArgs) ! {
	console.print_header('dagu stop')

	name := 'dagu'

	mut scr := screen.new()!
	scr.kill(name)!
}

pub fn start(args_ InstallArgs) ! {
	mut args := args_
	configure(args)!

	if check(args)! {
		return
	}

	console.print_header('dagu start')

	name := 'dagu'

	mut scr := screen.new()!

	mut s := scr.add(name: name, reset: true)!

	cmd2 := 'dagu server'

	s.cmd_send(cmd2)!

	for _ in 0 .. 50 {
		if check(args)! {
			return
		}
		time.sleep(100000)
	}
	return error('dagu did not install propertly, could not call api.')
}

pub fn check(args InstallArgs) !bool {
	// this checks health of dagu
	// curl http://localhost:3333/api/v1/s --oauth2-bearer 1234 works
	mut conn := httpconnection.new(name: 'dagu', url: 'http://localhost:3333/api/v1/')!
	if args.secret.len > 0 {
		conn.default_header.add(.authorization, 'Bearer ${args.secret}')
	}
	conn.default_header.add(.content_type, 'application/json')
	r := conn.get_json_dict(prefix: 'dags') or { return false }
	// r := conn.get_json_dict(prefix: 'dags')!
	dags := r['DAGs'] or { return false }
	// println(dags)
	// dags:=r["DAGs"] or {return error("can't find DAG's in json.\n$r")}
	// println(dags)
	// println(dags.arr().len)
	// if r.trim_space() == "OK" {
	// 	return true
	// }
	return true
}
