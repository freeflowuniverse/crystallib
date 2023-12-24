module vscode

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base

// install vscode will return true if it was already installed
pub fn install() ! {
	// base.install()!
	println(' - package_install install vscode')
	if !osal.done_exists('install_vscode') && !osal.cmd_exists('vscode') {
		mut url := ''
		if osal.platform() in [.alpine, .arch, .ubuntu] {
			if osal.cputype() == .arm {
				url = 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-arm64'
			} else {
				url = 'https://code.visualstudio.com/sha/download?build=stable&os=cli-alpine-x64'
			}
		} else if osal.platform() == .osx {
			if osal.cputype() == .arm {
				url = 'https://code.visualstudio.com/sha/download?build=stable&os=cli-darwin-arm64'
			} else {
				url = 'https://code.visualstudio.com/sha/download?build=stable&os=cli-darwin-x64'
			}
		}
		println(' download ${url}')
		mut dest := osal.download(
			url: url
			minsize_kb: 40000
			reset: true
			dest: '/tmp/vscode.zip'
			// expand_file: '/tmp/download/vscode'
		)!

		// osal.done_set('install_vscode', 'OK')!
	}
}
