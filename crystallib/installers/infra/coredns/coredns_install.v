module coredns

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.screen
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.clients.httpconnection
import os

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
	version := '1.11.1'

	res := os.execute('${osal.profile_path_source_and()} coredns version')
	if res.exit_code == 0 {
		r := res.output.split_into_lines().filter(it.trim_space().starts_with('CoreDNS-'))
		if r.len != 1 {
			return error("couldn't parse coredns version.\n${res.output}")
		}
		if texttools.version(version) > texttools.version(r[0].all_after_first('CoreDNS-')) {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset {
		console.print_header('install coredns')

		mut url := ''
		if osal.is_linux_arm() {
			url = 'https://github.com/coredns/coredns/releases/download/v${version}/coredns_${version}_linux_arm64.tgz'
		} else if osal.is_linux_intel() {
			url = 'https://github.com/coredns/coredns/releases/download/v${version}/coredns_${version}_linux_amd64.tgz'
		} else if osal.is_osx_arm() {
			url = 'https://github.com/coredns/coredns/releases/download/v${version}/coredns_${version}_darwin_arm64.tgz'
		} else if osal.is_osx_intel() {
			url = 'https://github.com/coredns/coredns/releases/download/v${version}/coredns_${version}_darwin_amd64.tgz'
		} else {
			return error('unsported platform')
		}

		mut dest := osal.download(
			url: url
			minsize_kb: 13000
			expand_dir: '/tmp/coredns'
		)!

		mut binpath := dest.file_get('coredns')!
		osal.cmd_add(
			cmdname: 'coredns'
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
	console.print_header('coredns stop')

	name := 'coredns'

	mut scr := screen.new()!
	scr.kill(name)!
}

pub fn configure(args_ InstallArgs) ! {
	mut args := args_
	dnszones_dir := '${os.home_dir()}/hero/cfg/dnszones'
	corednsconfigs_dir := '${os.home_dir()}/hero/cfg/corednsconfigs'

	mycode := $tmpl('templates/Corefile')
	testdbfile := $tmpl('templates/test.db')
	exampledbfile := $tmpl('templates/db.example.org')

	// example config
	mut path_exampleconfig := pathlib.get_file(path: '${corednsconfigs_dir}/test.db', create: true)!
	path_exampleconfig.template_write(testdbfile, true)!

	mut path_testzone := pathlib.get_file(path: '${dnszones_dir}/db.example.org', create: true)!
	path_testzone.template_write(exampledbfile, true)!

	mut path := pathlib.get_file(path: '${os.home_dir()}/hero/cfg/Corefile', create: true)!
	path.write(mycode)!
}

pub fn start(args_ InstallArgs) ! {
	mut args := args_
	configure(args)!

	if check()! {
		return
	}

	console.print_header('coredns start')

	name := 'coredns'

	mut scr := screen.new()!

	mut s := scr.add(name: name, reset: true)!

	cmd2 := "coredns -conf '${os.home_dir()}/hero/cfg/Corefile'"

	s.cmd_send(cmd2)!

	if !check()! {
		return error("coredns did not install propertly, do: curl 'http://localhost:3334/health'")
	}

	console.print_header('coredns running')
}

pub fn check() !bool {
	// this checks health of coredns
	mut conn := httpconnection.new(name: 'coredns', url: 'http://localhost:3334')!
	r := conn.get(prefix: 'health')!
	if r.trim_space() == 'OK' {
		return true
	}
	return false
}
