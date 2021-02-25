module installers

// import builder
// import nodejs
import os
import process
import myconfig
import gittools

pub fn digitaltwin_install(cfg &myconfig.ConfigRoot) ? {
	// nodejs.install(cfg)or {
	// 	return error(' ** ERROR: cannot install nodejs. Error was:\n$err')
	// }

	base := cfg.paths.base
	// nodejspath := cfg.nodejs.path

	// mut node := builder.node_get({}) or {
	// 	return error(' ** ERROR: cannot load node. Error was:\n$err')
	// }
	// node.platform_prepare() ?

	// checkout the repository
	mut gt := gittools.new(cfg.paths.code) ?

	url := 'https://github.com/threefoldtech/digitaltwin.git'
	mut repo := gt.repo_get_from_url(url: url, branch: 'master') or {
		return error('cannot pull digital twin git repo:\n$url\n$err')
	}

	if !os.exists('$repo.path/publisher/node_modules') {
		println(' - will install digitaltwin')

		script := '
			set -e
			export NVM_DIR=$base
			source $base/nvm.sh
			cd $repo.path/publisher

			npm install
			npm config set user 0
			npm install -g @hyperspace/cli

			'
		process.execute_silent(script) or {
			os.rmdir_all('$repo.path/publisher/node_modules') or { panic(err) }
			return error('cannot install digital twin.\n$err')
		}
	}

	println(' - digital twin installed')
}

pub fn digitaltwin_start(cfg &myconfig.ConfigRoot) ? {
	digitaltwin_install(cfg) ?
	base := cfg.paths.base

	mut gt := gittools.new(cfg.paths.code) ?

	url := 'https://github.com/threefoldtech/digitaltwin.git'
	mut repo := gt.repo_get_from_url(url: url, branch: 'master') or {
		return error('cannot pull digital twin git repo:\n$url\n$err')
	}

	println(' - will start digitaltwin')

	script := '
		set -e
		export NVM_DIR=$base
		source $base/nvm.sh
		cd $repo.path/publisher

		export PATH=$cfg.nodejs.path/bin:\$PATH

		node server.js

		'

	// TODO: need to have a config file being written for the digitaltwin server to use !!!
	// TODO: the config file is filled in from this tools

	// process.execute_silent(script) or { return error('cannot start digital twin.\n$err') }
	process.execute_interactive('$script') ?

	println(' - digital twin installed')
}
