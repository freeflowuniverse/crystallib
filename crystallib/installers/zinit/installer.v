module zinit

import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.zinit
// import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.core.texttools
// import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

// install zinit will return true if it was already installed
pub fn install(args InstallArgs) ! {
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}

	// make sure we install base on the node
	base.install()!

	if args.reset == false && osal.done_exists('install_zinit') {
		return
	}

	println(' - install zinit')

	build()!
	start()!

	// mut dest := osal.download(
	// 	// url: 'https://github.com/zinitserver/zinit/releases/download/v2.7.4/zinit_2.7.4_linux_amd64.tar.gz'
	// 	url: 'https://raw.githubusercontent.com/freeflowuniverse/freeflow_binary/main/x86_64/zinit'
	// 	minsize_kb: 5000
	// 	reset: true
	// 	// expand_dir: '/tmp/zinitserver'
	// )!

	osal.done_set('install_zinit', 'OK')!
	return
}

// start zinit
pub fn start() ! {
	zinit.start()!
}

// pub fn stop() ! {
// }

// pub fn restart() ! {
// 	stop()!
// 	start()!
// }
