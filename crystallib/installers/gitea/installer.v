module gitea

import freeflowuniverse.crystallib.installers.zinit as zinitinstaller
import freeflowuniverse.crystallib.installers.postgres as postgresinstaller
import freeflowuniverse.crystallib.installers.base
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.pathlib

pub fn install() ! {
	if osal.platform() != .ubuntu {
		return error('only support ubuntu for now')
	}

	if osal.done_exists('gitea_install') {
		println(' - gitea binaraies already installed')
		return
	}

	// make sure we install base on the node
	base.install()!
	postgresinstaller.install()!
	zinitinstaller.install()!

	version := '1.21.0'
	url := 'https://github.com/go-gitea/gitea/releases/download/v${version}/gitea-${version}-linux-amd64.xz'
	println(' download ${url}')
	mut dest := osal.download(
		url: url
		minsize_kb: 40000
		reset: true
		expand_file: '/tmp/download/gitea'
	)!

	binpath := pathlib.get_file(path: '/tmp/download/gitea', create: false)!
	osal.cmd_add(
		cmdname: 'gitea'
		source: binpath.path
	)!

	osal.done_set('gitea_install', 'OK')!

	println(' - gitea installed properly.')
}
