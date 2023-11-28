module golang

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base

const go_version = '1.20.6'

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

// install golang will return true if it was already installed
pub fn install(args InstallArgs) ! {
	// make sure we install base on the node
	base.install()!

	// install golang if it was already done will return true
	println(' - install golang')
	if !args.reset && osal.done_exists('install_golang') {
		println(' - go already installed')
		return
	}

	mut cmd := ''
	if osal.platform() == .osx {
		cmd = '
		cd /tmp
		rm -f ${golang.go_version}
		curl -L hhttps://go.dev/dl/go${golang.go_version}.darwin-amd64.pkg > go${golang.go_version}.darwin-amd64.pkg
		echo need to implement
		exit 1 
		'
		osal.profile_path_add('/usr/local/go/bin')!
	}
	if osal.platform() == .ubuntu {
		cmd = '
		cd /tmp
		rm -f go1.20.6.linux-amd64.tar.gz
		curl -L https://go.dev/dl/go${golang.go_version}.linux-amd64.tar.gz > go${golang.go_version}.linux-amd64.tar.gz
		rm -rf /usr/local/go
		tar -C /usr/local -xzf go${golang.go_version}.linux-amd64.tar.gz
		'
		osal.profile_path_add('/usr/local/go/bin')!
	} else {
		panic('only ubuntu and osx supported for now')
	}

	osal.execute_silent(cmd)!
	osal.done_set('install_golang', 'OK')!
	return
}
