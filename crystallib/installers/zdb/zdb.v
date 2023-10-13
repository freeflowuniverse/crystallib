module zdb

import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base

// install zdb will return true if it was already installed
pub fn install() ! {
	base.install()!
	println(' - package_install install zdb')
	if !osal.done_exists('install_zdb') && !osal.cmd_exists('zdb') {
		mut gs := gittools.get(root: '/tmp/code')!
		mut locator := gs.locator_new('git@github.com:threefoldtech/0-db.git')!
		mut gr := gs.repo_get(locator: locator, pull: true, reset: false)!
		cmd := '
		set -ex
		cd ${locator.path_on_fs()!.path}
		make
		sudo rsync -rav ${locator.path_on_fs()!.path}/bin/zdb* /usr/local/bin/
		'
		osal.execute_silent(cmd) or {
			return error('Cannot install zdb.\n${err}')
		}
		osal.done_set('install_zdb', 'OK')!
	}
}
