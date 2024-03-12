module rfs

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.osal.screen
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset   bool
}

pub fn install(args_ InstallArgs) ! {
	mut args := args_
	version := '2.0.5'

	res := os.execute('rfs --version')
	if res.exit_code == 0 {
		r := res.output.trim_space().split(' ')
		if r.len != 2 {
			return error("couldn't parse rfs version.\n${res.output}")
		}

		if texttools.version(version) > texttools.version(r[1]) {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset == false {
		return
	}

	console.print_header('install rfs')

	mut url := ''
	if osal.is_linux_intel() {
		url = 'https://github.com/threefoldtech/rfs/releases/download/v${version}/rfs'
	} else {
		return error('unsported platform')
	}

	mut dest := osal.download(
		url: url
		minsize_kb: 9000
		dest: '/tmp/rfs'
		reset: true
	)!

	osal.cmd_add(
		cmdname: 'rfs'
		source: '${dest.path}'
	)!
}

@[params]
pub struct PackArgs{
	meta_path string
	stores []string
	target string
	strip_password bool = true
}

pub fn pack(args PackArgs)!{
	console.print_header('rfs pack')

	install()!

	mut cmd := 'rfs pack --meta ${args.meta_path}'

	mut stores := ''
	for t in args.stores{
		stores += ' --store ${t}'
	}

	cmd += stores

	if !args.strip_password{
		cmd += ' --no-strip-password'
	}

	cmd += ' ${args.target}'
	osal.exec(cmd: cmd)!
}

@[params]
pub struct MountArgs{
	meta_path string
	cache_path ?string
	log_path ?string
	target string
}

pub fn mount(args MountArgs)!{
	console.print_header('rfs mount')

	install()!

	name := 'rfs'

	mut scr := screen.new()!

	mut s := scr.add(name: name, reset: true)!

	mut cmd := 'rfs mount --meta ${args.meta_path}'
	if cache_path := args.cache_path{
		cmd += ' --cache ${cache_path}'
	}

	if log_path := args.log_path{
		cmd += ' --log ${log_path}'
	}
	
	cmd += ' ${args.target}'

	s.cmd_send(cmd)!
}
