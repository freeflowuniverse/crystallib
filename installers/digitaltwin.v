module installers

// import builder
// import nodejs
import os
import process
import myconfig
import gittools

pub fn digitaltwin_install(mut cfg myconfig.ConfigRoot, update bool) ? {
	base := cfg.paths.base
	mut gt := gittools.new(cfg.paths.code) ?

	mut pull := update

	url := 'https://github.com/threefoldtech/digitaltwin.git'
	mut repo := gt.repo_get_from_url(url: url, branch: 'master', pull: pull) or {
		return error('cannot pull digital twin git repo:\n$url\n$err')
	}

	if !os.exists('$repo.path/publisher/node_modules') || update == true {
		println('- will make sure repo is up2date')
		repo.pull() ?

		println('- will download static files')

		cfg.update_staticfiles(true) ?

		println(' - will install digitaltwin')

		script := '
			set -e
			export NVM_DIR=$base
			source $base/nvm.sh
			cd $repo.path/publisher
			npm install
			pm2 update
			'
		process.execute_silent(script) or {
			os.rmdir_all('$repo.path/publisher/node_modules') or { panic(err) }
			return error('cannot install digital twin.\n$err')
		}
	}

	println(' - digital twin installed/updated')
}

pub fn digitaltwin_start(mut cfg myconfig.ConfigRoot, isproduction bool, update bool) ? {
	digitaltwin_install(mut cfg, update) ?
	base := cfg.paths.base

	mut gt := gittools.new(cfg.paths.code) ?

	url := 'https://github.com/threefoldtech/digitaltwin.git'
	mut repo := gt.repo_get_from_url(url: url, branch: 'master') or {
		return error('cannot pull digital twin git repo:\n$url\n$err')
	}

	println(' - will start digitaltwin')
	mut script := ''

	if !isproduction {
		script = '
				set -e
				export NVM_DIR=$base
				source $base/nvm.sh
				cd $repo.path/publisher

				export PATH=$cfg.nodejs.path/bin:\$PATH
				node server.js
				'
	} else {
		script = '
		set -e
		export NVM_DIR=$base
		source $base/nvm.sh
		cd $repo.path/publisher

		export PATH=$cfg.nodejs.path/bin:\$PATH
		export NODE_ENV=production
		pm2 start server.js
		pm2 save
		'
	}

	// TODO: need to have a config file being written for the digitaltwin server to use !!!
	// TODO: the config file is filled in from this tools

	// process.execute_silent(script) or { return error('cannot start digital twin.\n$err') }
	process.execute_interactive('$script') ?

	println(' - digital twin started')
}

pub fn digitaltwin_restart(mut cfg myconfig.ConfigRoot, isproduction bool) ? {
	base := cfg.paths.base

	mut gt := gittools.new(cfg.paths.code) ?

	url := 'https://github.com/threefoldtech/digitaltwin.git'
	mut repo := gt.repo_get_from_url(url: url, branch: 'master') or {
		return error('cannot pull digital twin git repo:\n$url\n$err')
	}

	println(' - will restart digitaltwin')
	mut script := ''

	if !isproduction {
		script = '
				set -e
				export NVM_DIR=$base
				source $base/nvm.sh
				cd $repo.path/publisher

				export PATH=$cfg.nodejs.path/bin:\$PATH
				pkill -9 node
				node server.js
				'
	} else {
		script = '
		set -e
		export NVM_DIR=$base
		source $base/nvm.sh
		cd $repo.path/publisher

		export PATH=$cfg.nodejs.path/bin:\$PATH
		export NODE_ENV=production
		echo "restartiong"
		pm2 restart server
		'
	}
	process.execute_interactive('$script') ?
	println(' - digital twin restarted')
}

pub fn digitaltwin_reload(mut cfg myconfig.ConfigRoot, isproduction bool) ? {
	base := cfg.paths.base

	println(' - will reload digitaltwin')
	mut script := ''

	if !isproduction {
		script = '
				set -e
				kill -10 `ps aux | grep "node server.js" | head -n 1 | tr -s " " | cut -d " " -f 2`
				'
	} else {
		script = '
		set -e
		export NVM_DIR=$base
		source $base/nvm.sh

		export PATH=$cfg.nodejs.path/bin:\$PATH
		export NODE_ENV=production
		kill -10 `pm2 pid server`
		'
	}
	process.execute_interactive('$script') ?
	println(' - digital twin restarted')
}

pub fn digitaltwin_stop(mut cfg myconfig.ConfigRoot, isproduction bool) ? {
	base := cfg.paths.base

	println(' - will stop digitaltwin')
	mut script := ''

	if !isproduction {
		script = '
				set -e
				kill -9 `ps aux | grep "node server.js" | head -n 1 | tr -s " " | cut -d " " -f 2`
				'
	} else {
		script = '
		set -e
		export NVM_DIR=$base
		source $base/nvm.sh

		export PATH=$cfg.nodejs.path/bin:\$PATH
		export NODE_ENV=production
		pm2 stop server
		'
	}
	process.execute_interactive('$script') ?
	println(' - digital twin reloaded')
}

pub fn digitaltwin_status(mut cfg myconfig.ConfigRoot, isproduction bool) ? {
	base := cfg.paths.base

	println(' - will check status of digitaltwin')
	mut script := ''

	if !isproduction {
		script = '
				set -e
				ps -C "node server"  >/dev/null && echo "Running" || echo "Not running"
				'
	} else {
		script = '
		set -e
		export NVM_DIR=$base
		source $base/nvm.sh

		export PATH=$cfg.nodejs.path/bin:\$PATH
		export NODE_ENV=production
		pm2 status server
		'
	}
	process.execute_interactive('$script') ?
}

pub fn digitaltwin_logs(mut cfg myconfig.ConfigRoot, isproduction bool) ? {
	base := cfg.paths.base

	println(' - will check logs of digitaltwin')
	mut script := ''

	if !isproduction {
		script = '
				set -e
				echo "Check logs @ ~/codewww/github/threefoldtech/digitaltwin/publisher/logs"
				'
	} else {
		script = '
		set -e
		export NVM_DIR=$base
		source $base/nvm.sh

		export PATH=$cfg.nodejs.path/bin:\$PATH
		export NODE_ENV=production
		pm2 logs server
		'
	}
	process.execute_interactive('$script') ?
}
