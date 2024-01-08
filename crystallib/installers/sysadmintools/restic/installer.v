module restic

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.core.texttools
// import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

// install restic will return true if it was already installed
pub fn install(args InstallArgs) ! {
	if args.reset == false && osal.done_exists('install_restic') && osal.cmd_exists('restic') {
		console.print_header('restic already installed')
		return
	}

	console.print_header('install restic')

	mut url := ''
	mut binpath_ := ''
	if osal.is_ubuntu() {
		url = 'https://github.com/restic/restic/releases/download/v0.16.2/restic_0.16.2_linux_amd64.bz2'
		binpath_ = '/tmp/restic_0.16.2_linux_amd64'
	} else if osal.is_osx_arm() {
		url = 'https://github.com/restic/restic/releases/download/v0.16.2/restic_0.16.2_darwin_arm64.bz2'
		binpath_ = '/tmp/restic_0.16.2_darwin_arm64'
	} else {
		return error('only support ubuntu & osx arm for now')
	}

	// make sure we install base on the node
	base.install()!

	mut dest := osal.download(
		url: url
		minsize_kb: 5000
		reset: true
		expand_dir: '/tmp/restic'
	)!

	osal.cmd_add(
		cmdname: 'restic'
		source: binpath_
	)!

	osal.done_set('install_restic', 'OK')!

	return
}

// start restic
pub fn start() ! {
}

pub fn stop() ! {
}

pub fn restart() ! {
	stop()!
	start()!
}
