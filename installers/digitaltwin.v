module installers

// import builder
// import nodejs
import os
import process
import publisher.config
import gittools

pub fn digitaltwin_install(update bool) ? {
	mut conf := config.get()?
	base := conf.publish.paths.base
	mut gt := gittools.get()?
	mut pull := update

	url := 'https://github.com/threefoldtech/twin_server/'
	mut repo := gt.repo_get_from_url(url: url, branch: 'main', pull: pull) or {
		return error('cannot pull digital twin git repo:\n$url\n$err')
	}

	if !os.exists('$repo.path()/src/node_modules') || update == true {
		println('- will make sure repo is up2date')
		repo.pull()?

		println('- will download static files')

		conf.update_staticfiles(true)?

		println(' - will install digitaltwin')

		script := '
			set -e
			export NVM_DIR=$base
			source $base/nvm.sh
			cd $repo.path()/src
			npm install
			mkdir -p \$HOME/appdata/user
			mkdir -p \$HOME/appdata/chats
			'
		process.execute_silent(script) or {
			print(err)
			os.rmdir_all('$repo.path()/src/node_modules') or {}
			return error('cannot install digital twin.\n$err')
		}
	}

	println(' - digital twin installed/updated')
}

pub fn digitaltwin_start(isproduction bool, update bool) ? {
	mut conf := config.get()?

	digitaltwin_install(update)?
	base := conf.publish.paths.base

	mut gt := gittools.get()?

	url := 'https://github.com/threefoldtech/twin_server/'
	mut repo := gt.repo_get_from_url(url: url, branch: 'main') or {
		return error('cannot pull digital twin git repo:\n$url\n$err')
	}

	println(' - will start digitaltwin')
	mut script := ''

	if !isproduction {
		script = '
				set -e
				tmux new -d -s "digitaltwin"
				tmux send-keys -t digitaltwin.0 "export BASEDIR=\$HOME/appdata/" ENTER
				tmux send-keys -t digitaltwin.0 "export NVM_DIR=$base && source $base/nvm.sh && cd $repo.path()/src" ENTER
				tmux send-keys -t digitaltwin.0 "export PATH=$conf.nodejs.path/bin:\$PATH" ENTER
				tmux send-keys -t digitaltwin.0 "node server.js" ENTER
				tmux new-window -t digitaltwin:1
				tmux send-keys -t digitaltwin:1 "cd $base/config && publishtools removechanges && publishtools develop" ENTER
				'
	} else {
		script = '
		tmux new -d -s "digitaltwin"
		tmux send-keys -t digitaltwin.0 "export BASEDIR=\$HOME/appdata" ENTER
		tmux send-keys -t digitaltwin.0 "export ENABLE_SSL=\$ENABLE_SSL" ENTER
		tmux send-keys -t digitaltwin.0 "export THREEBOT_PHRASE=\'\$THREEBOT_PHRASE\'" ENTER
		tmux send-keys -t digitaltwin.0 "export SECRET=\$SECRET" ENTER
		tmux send-keys -t digitaltwin.0 "export NVM_DIR=$base" ENTER
		tmux send-keys -t digitaltwin.0 "source $base/nvm.sh" ENTER
		#tmux send-keys -t digitaltwin.0 "nvm use --lts" ENTER
		tmux send-keys -t digitaltwin.0 "cd $repo.path()/src" ENTER
		tmux send-keys -t digitaltwin.0 "WIKI_FS=true  NODE_ENV=production node server.js || echo \\"can not run\\" " ENTER
		tmux new-window -t digitaltwin:1
		tmux send-keys -t digitaltwin:1 "cd $base/config && publishtools removechanges && publishtools develop" ENTER
		'
	}
	process.execute_interactive('$script')?
	println(' - digital twin started')
}

pub fn digitaltwin_restart(isproduction bool) ? {
	mut conf := config.get()?

	base := conf.publish.paths.base
	mut gt := gittools.get()?

	url := 'https://github.com/threefoldtech/twin_server/'
	mut repo := gt.repo_get_from_url(url: url, branch: 'main') or {
		return error('cannot pull digital twin git repo:\n$url\n$err')
	}

	println(' - will restart digitaltwin')

	mut script := ''
	if !isproduction {
		script = '
				set -e
				tmux kill-session -t digitaltwin
				tmux new -d -s "digitaltwin"
				tmux send-keys -t digitaltwin.0 "export NVM_DIR=$base && source $base/nvm.sh && cd $repo.path()/src" ENTER
				tmux send-keys -t digitaltwin.0 "export PATH=$conf.nodejs.path/bin:\$PATH" ENTER
				tmux send-keys -t digitaltwin.0 "node server.js" ENTER
				tmux new-window -t digitaltwin:1
				tmux send-keys -t digitaltwin:1 "cd $base/config && publishtools removechanges && publishtools develop" ENTER
				'
	} else {
		script = '
		tmux kill-session -t digitaltwin
		source ~/.bashrc
		tmux new -d -s "digitaltwin"
		
		tmux send-keys -t digitaltwin.0 "export ENABLE_SSL=\$ENABLE_SSL" ENTER
		tmux send-keys -t digitaltwin.0 "export THREEBOT_PHRASE=\'\$THREEBOT_PHRASE\'" ENTER
		tmux send-keys -t digitaltwin.0 "export SECRET=\$SECRET" ENTER
		tmux send-keys -t digitaltwin.0 "export NVM_DIR=$base" ENTER
		tmux send-keys -t digitaltwin.0 "source $base/nvm.sh" ENTER
		#tmux send-keys -t digitaltwin.0 "nvm use --lts" ENTER
		tmux send-keys -t digitaltwin.0 "cd $repo.path()/src" ENTER
		tmux send-keys -t digitaltwin.0 "WIKI_FS=true  NODE_ENV=production node server.js || echo \\"can not run\\" " ENTER
		tmux new-window -t digitaltwin:1
		tmux send-keys -t digitaltwin:1 "cd $base/config && publishtools removechanges && publishtools develop" ENTER
		'
	}

	process.execute_interactive('$script')?
	println(' - digital twin restarted')
}

pub fn digitaltwin_reload(isproduction bool) ? {
	println(' - will reload digitaltwin')
	mut conf := config.get()?
	base := conf.publish.paths.base
	mut script := '
				set -e
				kill -10 `ps aux | grep "node server.js" | head -n 1 | tr -s " " | cut -d " " -f 2`
				tmux kill-window  -t digitaltwin:1
				tmux new-window -t digitaltwin:1
				tmux send-keys -t digitaltwin:1 "cd $base/config && publishtools removechanges && publishtools develop" ENTER
				'
	process.execute_interactive('$script')?
	println(' - digital twin restarted')
}

pub fn digitaltwin_stop(isproduction bool) ? {
	println(' - will stop digitaltwin')
	script := 'tmux kill-session -t digitaltwin'
	process.execute_interactive('$script')?
	println(' - digital twin reloaded')
}

pub fn digitaltwin_status(isproduction bool) ? {
	println(' - will check status of digitaltwin')
	script := '
				set -e
				ps -C "node server.js"  >/dev/null && echo "Running" || echo "Not running"
				'
	process.execute_interactive('$script')?
}

pub fn digitaltwin_logs(isproduction bool) ? {
	println(' - will check logs of digitaltwin')
	// process.execute_interactive('$script') ?
}
