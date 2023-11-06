module zdb

import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base

// install zdb will return true if it was already installed
pub fn install() ! {
	base.install()!
	println(' - package_install install zdb')
	if !osal.done_exists('install_zdb') && !osal.cmd_exists('zdb') {
		path := gittools.code_get(url: 'git@github.com:threefoldtech/0-db.git', reset: false, pull: true)!
		cmd := '
		set -ex
		cd ${path}
		make
		sudo rsync -rav ${path}/bin/zdb* /usr/local/bin/
		'
		osal.execute_silent(cmd) or { return error('Cannot install zdb.\n${err}') }
		osal.done_set('install_zdb', 'OK')!
	}
}
