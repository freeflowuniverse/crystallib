module rfse

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.osal.screen
import freeflowuniverse.crystallib.installers.sysadmintools.rfse as fungi

@[params]
pub struct PackArgs {
	meta_path      string
	stores         []string
	target         string
	strip_password bool = true
}

pub fn pack(args PackArgs) ! {
	console.print_header('rfs pack')

	fungi.install()!

	mut cmd := 'rfs pack --meta ${args.meta_path}'

	mut stores := ''
	for t in args.stores {
		stores += ' --store ${t}'
	}

	cmd += stores

	if !args.strip_password {
		cmd += ' --no-strip-password'
	}

	cmd += ' ${args.target}'
	osal.exec(cmd: cmd)!
}

@[params]
pub struct MountArgs {
	meta_path  string
	cache_path ?string
	log_path   ?string
	target     string
}

pub fn mount(args MountArgs) ! {
	console.print_header('rfs mount')

	fungi.install()!

	name := 'rfs'

	mut scr := screen.new()!

	mut s := scr.add(name: name, reset: true)!

	mut cmd := 'rfs mount --meta ${args.meta_path} '
	if cache_path := args.cache_path {
		cmd += ' --cache ${cache_path}'
	}

	if log_path := args.log_path {
		cmd += ' --log ${log_path}'
	}

	cmd += ' ${args.target}'
	s.cmd_send(cmd)!
}
