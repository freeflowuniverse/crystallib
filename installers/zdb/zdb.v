module zdb

import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.installers.base

// install zdb will return true if it was already installed
pub fn  install() ! {
	base.install()!
	println(' - package_install install zdb')
	if !osal.done_exists('install_zdb') && !cmd_exists('zdb') {
		mut gs := gittools.get(root: '/tmp/code')!
		url := 'git@github.com:threefoldtech/0-db.git'
		mut gr := gs.repo_get_from_url(url: url, pull: true, reset: false)!
		cmd := '
		set -ex
		cd ${gr.path}
		make
		sudo rsync -rav ${gr.path}/bin/zdb* /usr/local/bin/
		'
		osal.exec_silent('Cannot install zdb.\n${err}')!
		osal.done_set('install_zdb', 'OK')!
	}
}
