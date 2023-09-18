module golang

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base

const go_version = '1.20.6'

// install golang will return true if it was already installed
pub fn install() ! {
	// make sure we install base on the node
	base.install()!

	// install golang if it was already done will return true
	println(' - package_install install golang')
	if osal.done_exists('install_golang') {
		println('    package_install was already done')
		return
	}

	if cmd_exists('go') {
		println('Golang was already installed.')
		osal.done_set('install_golang', 'OK')!
		return
	}

	if osal.platform() == .osx {
		cmd := '
		cd /tmp
		rm -f ${golang.go_version}
		curl -L hhttps://go.dev/dl/go${golang.go_version}.darwin-amd64.pkg > go${golang.go_version}.darwin-amd64.pkg
		echo need to implement
		exit 1 
		echo \'export PATH=${PATH}:/usr/local/go/bin\' >> ${HOME}/.profile
		'
	} osal.platform() == .ubuntu {
		cmd := '
		cd /tmp
		rm -f go1.20.6.linux-amd64.tar.gz
		curl -L https://go.dev/dl/go${golang.go_version}.linux-amd64.tar.gz > go${golang.go_version}.linux-amd64.tar.gz
		rm -rf /usr/local/go
		tar -C /usr/local -xzf go${golang.go_version}.linux-amd64.tar.gz
		#TODO: should use a replacement command rather than just adding e.g. use line editor
		echo \'export PATH=${PATH}:/usr/local/go/bin\' >> ${HOME}/.profile
		'
	} else {
		panic('only ubuntu and osx supported for now')
	}

	osal.execute_silent('Cannot install golang.\n${err}') 	
	osal.done_set('install_golang', 'OK')!
	return
}
