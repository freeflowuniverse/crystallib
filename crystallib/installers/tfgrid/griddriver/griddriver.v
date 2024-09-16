module griddriver

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.installers.lang.golang
import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.core.texttools
import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

pub fn install(args_ InstallArgs) ! {
	mut args := args_

	res := os.execute('${osal.profile_path_source_and()} griddriver')
	if res.exit_code != 0 {
		args.reset = true
	}

	if args.reset {
		console.print_header('install griddriver')
		build()!
	}
}

pub fn build() ! {
	golang.install()!
	mut dest_on_os := '${os.home_dir()}/hero/bin'
	if osal.is_linux() {
		dest_on_os = '/usr/local/bin'
	}
	path := gittools.code_get(
		url: 'https://github.com/threefoldtech/web3gw'
		reset: true
		pull: true
	)!
	cmd := '
	set -ex
	cd ${path}
	cd griddriver
	go env -w CGO_ENABLED="0"
	go build -o ${path}/griddriver/bin/griddriver
	echo build ok
	sudo cp ${path}/griddriver/bin/griddriver ${dest_on_os}/
	'
	console.print_header('build griddriver')
	osal.execute_stdout(cmd)!
	console.print_header('build griddriver OK')
}
