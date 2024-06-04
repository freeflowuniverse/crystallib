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
	reset     bool
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
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}
	console.print_header('build griddriver')
	path := gittools.code_get(
		url: 'https://github.com/threefoldtech/web3gw'
		reset: true
		pull: true
	)!
	cmd := '
	cd ${path}
	cd griddriver
	./build.sh
	'
	// check if sudo in ./build.sh will work
	// https://github.com/threefoldtech/web3gw/blob/development_integration/griddriver/build.sh
	console.print_header('build griddriver')
	osal.execute_stdout(cmd)!
	console.print_header('build griddriver OK')
}
