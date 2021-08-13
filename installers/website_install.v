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
	multibranch := conf.publish.multibranch
	nodejspath := conf.nodejs.path

	mut gt := gittools.new(codepath, multibranch) or { return error('ERROR: cannot load gittools:$err') }
	// println(" - install repo: $name")
	mut repo := gt.repo_get(name:name) or { return error('ERROR: cannot load gittools, cannot find reponame:$name \n$err') }
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
	
	#set +e
	#source $base/nvm.sh
	#set -e

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

	#set +e
	#source $base/nvm.sh
	#set -e
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

	#set +e
	#source $base/nvm.sh
	#set -e
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

	package_json :='
	{
	"name": "$name",
	"private": true,
	"scripts": {
		"build": "gridsome build",
		"develop": "gridsome develop",
		"explore": "gridsome explore"
	},
	"dependencies": {
		"@fortawesome/fontawesome-svg-core": "^1.2.30",
		"@fortawesome/free-brands-svg-icons": "^5.14.0",
		"@fortawesome/free-solid-svg-icons": "^5.14.0",
		"@fortawesome/vue-fontawesome": "^2.0.0",
		"@gridsome/source-filesystem": "^0.6.2",
		"@gridsome/transformer-remark": "^0.6.2",
		"@noxify/gridsome-remark-classes": "^1.0.0",
		"@noxify/gridsome-remark-table-align": "^1.0.0",
		"axios": "^0.21.1",
		"babel-runtime": "^6.26.0",
		"core-js": "^3.6.5",
		"gridsome": "^0.7.3",
		"gridsome-plugin-matomo": "^0.1.0",
		"gridsome-plugin-remark-prismjs-all": "^0.3.5",
		"gridsome-plugin-tailwindcss": "^3.0.1",
		"gridsome-source-graphql": "^1.0.2",
		"gridsome-source-static-meta": "github:noxify/gridsome-source-static-meta#master",
		"lodash": "^4.17.20",
		"pluralize": "^8.0.0",
		"sass-loader": "^10.0.2",
		"tailwindcss": "^2.0.0",
		"tailwindcss-gradients": "^3.0.0",
		"tailwindcss-tables": "^0.4.0",
		"v-tooltip": "^2.0.3",
		"vue-markdown": "^2.1.2",
		"isexe": "^2.0.0",
		"vue-share-it": "^1.1.4",
		"node-sass": "^6.0.1"
		},
		"devDependencies": {
			"@tailwindcss/aspect-ratio": "^0.2.0"
		}
	}
	'

	//REMARK: changed tailwind css to 2.x series, maybe that is not good

	os.write_file('$repo.path_get()/install.sh', texttools.dedent(script_install)) or {
		return error('cannot write to $repo.path_get()/install.sh\n$err')
	}
	os.write_file('$repo.path_get()/run.sh', texttools.dedent(script_run)) or {
		return error('cannot write to $repo.path_get()/run.sh\n$err')
	}
	os.write_file('$repo.path_get()/build.sh', texttools.dedent(script_build)) or {
		return error('cannot write to $repo.path_get()/build.sh\n$err')
	}

	os.write_file('$repo.path_get()/package.json', texttools.dedent(package_json)) or {
		return error('cannot write to $repo.path_get()/package.json\n$err')
	}	

	os.chmod('$repo.path_get()/install.sh', 0o700)
	os.chmod('$repo.path_get()/run.sh', 0o700)
	os.chmod('$repo.path_get()/build.sh', 0o700)

	println('   > node modules install')
	process.execute_silent(script_install) or {
		return error('cannot install node modules for ${name}.\n$err')
	}

	// only require threebot_data in case of gridsome website
	if os.exists('$repo.path_get()/gridsome.config.js'){
		mut datarepo := gt.repo_get(name: 'threefold_data') or {
			return error('ERROR: cannot get repo:$err')
		}
	
		for x in ['blog', 'person', 'news', 'project'] {
			if os.exists('$repo.path_get()/content') {
				process.execute_silent('rm -rf $repo.path_get()/content/$x\n') ?
				os.symlink('$datarepo.path_get()/content/$x',
					'$repo.path_get()/content/$x') or {
					return error('Cannot link $x from data path to repo.path_get().\n$err')
				}
			}
		}
	}

	os.write_file('$repo.path_get()/.installed', '') or {
		return error('cannot write to $repo.path_get()/.installed\n$err')
	}
}
