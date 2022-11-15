module zdb

import freeflowuniverse.crystallib.gittools
import freeflowuniverse.crystallib.installers.base

// install zdb will return true if it was already installed
pub fn (mut i Installer) install() ! {
	base.install()!
	mut node := i.node
	println(' - $node.name: install zdb')
	if !node.done_exists('install_zdb') && !node.command_exists('zdb') {
		mut gs := gittools.get(root: '/tmp/code')!
		url := 'git@github.com:threefoldtech/0-db.git'
		mut gr := gs.repo_get_from_url(url: url, pull: true, reset: false)!
		cmd := '
		set -ex
		cd ${gr.path}
		make
		sudo rsync -rav ${gr.path}/bin/zdb* /usr/local/bin/
		'
		node.exec(cmd) or { return error('Cannot install zdb.\n$err') }
		node.done_set('install_zdb', 'OK')!
	}
}
