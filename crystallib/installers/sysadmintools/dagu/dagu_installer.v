module dagu

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.clients.httpconnection
import freeflowuniverse.crystallib.sysadmin.startupmanager
import os
import time

@[params]
pub struct InstallArgs {
pub mut:
	reset   bool
	start   bool = true
	restart bool
	passwd  string
	secret  string
	title   string
}

pub fn install(args_ InstallArgs) ! {
	mut args := args_
	version := '1.12.11'

	res := os.execute('${osal.profile_path_source_and()} dagu version')
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

pub fn restart(args_ InstallArgs) ! {
	stop(args_)!
	start(args_)!
}

pub fn stop(args_ InstallArgs) ! {
	console.print_header('dagu stop')
	mut sm := startupmanager.get()!
	sm.kill('dagu')!
}

pub fn start(args_ InstallArgs) ! {
	mut args := args_

	if args.title == '' {
		args.title = 'HERO DAG'
	}

	if check(args)! {
		return
	}

	console.print_header('dagu start')

	myconfigpath_ := '${os.home_dir()}/hero/cfg/dagu.yaml'
	homedir := '${os.home_dir()}/hero/var/dagu'

	//FILL IN THE TEMPLATE
	mut mycode := $tmpl('templates/admin.yaml')

	mut path := pathlib.get_file(path: myconfigpath_, create: true)!
	path.write(mycode)!

	mut sm := startupmanager.get()!

	cmd := 'dagu server --config ${myconfigpath_}'

	sm.start(
		name: 'dagu'
		cmd: cmd
	)!

	console.print_debug(cmd)

	for _ in 0 .. 50 {
		if check(args)! {
			return
		}
		time.sleep(100 * time.millisecond)
	}
	return error('dagu did not install propertly, could not call api.')
}

pub fn check(args InstallArgs) !bool {
	// this checks health of dagu
	// curl http://localhost:3333/api/v1/s --oauth2-bearer 1234 works
	mut conn := httpconnection.new(name: 'dagu', url: 'http://localhost:3333/api/v1/')!

	// console.print_debug("curl http://localhost:3333/api/v1/dags --oauth2-bearer ${secret}")
	conn.default_header.add(.authorization, 'Bearer ${args.secret}')
	conn.default_header.add(.content_type, 'application/json')
	console.print_debug('check connection to dagu')
	// r := conn.get_json_dict(prefix: 'dags') or { return false }
	r := conn.get_json_dict(prefix: 'dags', debug: false)!
	dags := r['DAGs'] or { return false }
	// println(dags)
	console.print_debug('Dagu is answering.')
	return true
}

