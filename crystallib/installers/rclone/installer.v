module rclone

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.core.texttools
// import os

[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

// install rclone will return true if it was already installed
pub fn install(args InstallArgs) ! {
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}


	if args.reset == false && osal.done_exists('install_rclone') && osal.cmd_exists('rclone') {
		return
	}

	println(' - install rclone')

	// make sure we install base on the node
	base.install()!

	mut dest := osal.download(
		// url: 'https://github.com/rcloneserver/rclone/releases/download/v2.7.4/rclone_2.7.4_linux_amd64.tar.gz'
		url: 'https://downloads.rclone.org/v1.64.2/rclone-v1.64.2-linux-amd64.zip'
		// https://github.com/rclone/rclone/releases/download/v1.64.2/rclone-v1.64.2-linux-amd64.zip
		minsize_kb: 5000
		reset: true
		expand_dir: '/tmp/rclone'
	)!

	//will find the one dir in the destination and move that one up 1 level
	dest.moveup_single_subdir()!

	mut binpath:=dest.file_get("rclone")!
	binpath.move(dest:"/usr/local/bin/rclone",delete:true)!
	
	osal.done_set('install_rclone', 'OK')!

	return
}

// start rclone
pub fn start() ! {
}

pub fn stop() ! {
}

pub fn restart() ! {
	stop()!
	start()!
}
