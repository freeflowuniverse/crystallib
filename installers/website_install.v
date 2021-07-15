module installers

import os
import despiegk.crystallib.publisher_config
import despiegk.crystallib.process
import despiegk.crystallib.gittools
import despiegk.crystallib.texttools

// Initialize (load wikis) only once when server starts
pub fn website_install(name string, first bool, conf &publisher_config.ConfigRoot) ? {
	base := conf.publish.paths.base
	codepath := conf.publish.paths.code
	nodejspath := conf.nodejs.path

	mut gt := gittools.new(codepath,false) or { return error('ERROR: cannot load gittools:$err') }
	reponame := conf.reponame(name) ?
	mut repo := gt.repo_get(name: reponame) or { return error('ERROR: cannot load gittools:$err') }
	println(' - install website on $repo.path_get()')

	if conf.publish.reset {
		script6 := '
		
		cd $repo.path_get()

		rm -rf modules
		rm -f .installed
		rm -f src/errors.md

		'
		println('   > reset')
		process.execute_silent(script6) or {
			return error('cannot install node modules for ${name}.\n$err')
		}
	}

	if conf.publish.pull {
		script7 := '
		
		cd $repo.path_get()

		git pull

		'
		println('   > pull')
		process.execute_silent(script7) or { return error('cannot pull code for ${name}.\n$err') }
	}

	if os.exists('$repo.path_get()/.installed') {
		return
	}

	script_install := '

	set -e

	cd $repo.path_get()

	rm -f yarn.lock
	rm -rf .cache		
	
	set +e
	source $base/nvm.sh
	set -e

	if [ "$first" = "true" ]; then
		#nvm use --lts
		npm install
		rsync -ra --delete node_modules/ $base/node_modules/
	else
		rsync -ra --delete $base/node_modules/ node_modules/ 
		#nvm use --lts
		npm install
	fi



	'

	if nodejspath.len == 0 {
		panic('nodejspath needs to be set')
	}

	script_run := '

	set -e
	cd $repo.path_get()

	#need to ignore errors for getting nvm not sure why
	set +e
	source $base/nvm.sh

	set -e
	#nvm use --lts

	export PATH=$nodejspath/bin:\$PATH

	if [ -f vue.config.js ]; then
    	npm run-script serve
	else
		gridsome develop
	fi
	
	'

	script_build := '

	set -e
	cd $repo.path_get()

	#need to ignore errors for getting nvm not sure why
	set +e
	source $base/nvm.sh

	set -e
	#nvm use --lts

	export PATH=$nodejspath/bin:\$PATH

	set +e
	if [ -f vue.config.js ]; then
    	npm run-script build
	else
		gridsome build
	fi

	set -e

	mkdir -p $conf.publish.paths.publish/$name
	rsync -ra --delete $repo.path_get()/dist/ $conf.publish.paths.publish/$name/

	cd $repo.path_get()/dist

	#echo go to http://localhost:9999/
 	#python3 -m http.server 9999

	'

	os.write_file('$repo.path_get()/install.sh', texttools.dedent(script_install)) or {
		return error('cannot write to $repo.path_get()/install.sh\n$err')
	}
	os.write_file('$repo.path_get()/run.sh', texttools.dedent(script_run)) or {
		return error('cannot write to $repo.path_get()/run.sh\n$err')
	}
	os.write_file('$repo.path_get()/build.sh', texttools.dedent(script_build)) or {
		return error('cannot write to $repo.path_get()/build.sh\n$err')
	}

	os.chmod('$repo.path_get()/install.sh', 0o700)
	os.chmod('$repo.path_get()/run.sh', 0o700)
	os.chmod('$repo.path_get()/build.sh', 0o700)

	println('   > node modules install')
	process.execute_silent(script_install) or {
		return error('cannot install node modules for ${name}.\n$err')
	}

	// println(job)

	// process.execute_silent("mkdir -p $repo.path_get()/content") ?

	for x in ['blog', 'person', 'news', 'project'] {
		if os.exists('$repo.path_get()/content') {
			process.execute_silent('rm -rf $repo.path_get()/content/$x\n') ?
			os.symlink('$codepath/github/threefoldfoundation/data_threefold/content/$x',
				'$repo.path_get()/content/$x') or {
				return error('Cannot link $x from data path to repo.path_get().\n$err')
			}
		}
	}

	os.write_file('$repo.path_get()/.installed', '') or {
		return error('cannot write to $repo.path_get()/.installed\n$err')
	}
}
