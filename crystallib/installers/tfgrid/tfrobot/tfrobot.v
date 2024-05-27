module tfrobot

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.installers.lang.golang
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.core.texttools
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset     bool
	uninstall bool
}

pub fn install(args_ InstallArgs) ! {
	mut args := args_
	version := '0.14.0'

	res := os.execute('${osal.profile_path_source_and()} tfrobot version')
	if res.exit_code == 0 {
		r := res.output.split_into_lines().filter(it.trim_space().contains('v0.'))
		if r.len != 1 {
			console.print_debug(r)
			return error("couldn't parse tfrobot version.\n${res.output}")
		}
		if texttools.version(version) > texttools.version(r[0].replace('v', '')) {
			args.reset = true
		}
	} else {
		args.reset = true
	}

	if args.reset {
		console.print_header('install tfrobot')
		build()!
	}
}

pub fn build() ! {
	golang.install()!
	console.print_header('build tfrobot')
	mut dest_on_os := '${os.home_dir()}/hero/bin'
	if osal.is_linux() {
		dest_on_os = '/usr/local/bin'
	}
	path := gittools.code_get(
		url: 'https://github.com/threefoldtech/tfgrid-sdk-go'
		reset: true
		pull: true
	)!
	cmd := '
	cd ${path}
	cd mass-deployer
	make build
	cp ${path}/mass-deployer/bin/tfrobot ${dest_on_os}/
	'
	console.print_header('build tfrobot')
	osal.execute_stdout(cmd)!
	console.print_header('build tfrobot OK')
}
