module restic

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.core.texttools
// import os

[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

// install restic will return true if it was already installed
pub fn install(args InstallArgs) ! {
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}

	if args.reset == false && osal.done_exists('install_restic') && osal.cmd_exists('restic') {
		println(' - restic already installed')
		return
	}

	println(' - install restic')

	// make sure we install base on the node
	base.install()!

	mut binpath := pathlib.get_file(path: '/tmp/restic_0.16.2_linux_amd64', delete: true)!

	mut dest := osal.download(
		url: 'https://github.com/restic/restic/releases/download/v0.16.2/restic_0.16.2_linux_amd64.bz2'
		minsize_kb: 5000
		reset: true
		expand_dir: '/tmp/restic'
	)!

	binpath.move(dest: '/usr/local/bin/restic', delete: true, chmod_execute: true)!

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
