module installers

import os
import despiegk.crystallib.publisher_config
import despiegk.crystallib.process
import despiegk.crystallib.gittools
import despiegk.crystallib.texttools

// Initialize (load wikis) only once when server starts
pub fn website_install(site_conf publisher_config.SiteConfig, first bool, conf &publisher_config.ConfigRoot) ? {
	name := site_conf.reponame
	base := conf.publish.paths.base
	// codepath := conf.publish.paths.code
	// multibranch := conf.publish.multibranch
	nodejspath := conf.nodejs.path
	mut path := site_conf.path

	mut gt := gittools.new(conf.publish.paths.code, conf.publish.multibranch) or { return error('ERROR: cannot load gittools:$err') }
	
	println(' - install website on $path')

	if conf.publish.reset || site_conf.reset {
		script6 := '
		#!/usr/bin/env bash
		cd $path

		rm -rf modules
		rm -f .installed
		rm -f src/errors.md

		'
		println('   > reset')
		process.execute_silent(script6) or {
			return error('cannot install node modules for ${name}.\n$err')
		}
	}

	if os.exists('$path/.installed') {
		return
	}

	mut nvm_line := ""
	if conf.nodejs.nvm {
		nvm_line = "source $base/nvm.sh && nvm use --lts && export PATH=$nodejspath/bin:\$PATH"
	}

	script_install := '
	#!/usr/bin/env bash
	$nvm_line

	set -e

	cd $path

	rm -f yarn.lock
	rm -rf .cache		
	
	if [ "$first" = "true" ]; then
		npm install
		rsync -ra --delete node_modules/ $base/node_modules/
	else
		rsync -ra --delete $base/node_modules/ node_modules/ 
		npm install
	fi

	'
	script_run := '
	#!/usr/bin/env bash
	$nvm_line

	set -e
	cd $path

	if [ -f vue.config.js ]; then
    	npm run-script serve
	else
		gridsome develop
	fi
	
	'

	script_build := '
	#!/usr/bin/env bash

	$nvm_line

	set -e
	cd $path


	set +e
	if [ -f vue.config.js ]; then
    	npm run-script build
	else
		gridsome build
	fi

	set -e

	mkdir -p $conf.publish.paths.publish/$name
	rsync -ra --delete $path/dist/ $conf.publish.paths.publish/$name/

	cd $path/dist

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
			"isexe": "^2.0.0",
			"lodash": "^4.17.20",
			"node-sass": "^5.0.0",
			"pluralize": "^8.0.0",
			"sass-loader": "^10.0.2",
			"tailwindcss": "^1.8.4",
			"tailwindcss-gradients": "^3.0.0",
			"tailwindcss-tables": "^0.4.0",
			"v-tooltip": "^2.0.3",
			"vue-markdown": "^2.1.2",
			"vue-share-it": "^1.1.4",
			"vue-slick-carousel": "^1.0.6"
		},
		"devDependencies": {
			"@tailwindcss/aspect-ratio": "^0.2.0"
		}
	}
	'

	os.write_file('$path/install', texttools.dedent(script_install)) or {
		return error('cannot write to $path/install.sh\n$err')
	}
	os.write_file('$path/run', texttools.dedent(script_run)) or {
		return error('cannot write to $path/run.sh\n$err')
	}
	os.write_file('$path/build', texttools.dedent(script_build)) or {
		return error('cannot write to $path/build.sh\n$err')
	}

	os.write_file('$path/package.json', texttools.dedent(package_json)) or {
		return error('cannot write to $path/package.json\n$err')
	}	

	os.chmod('$path/install', 0o700)
	os.chmod('$path/run', 0o700)
	os.chmod('$path/build', 0o700)

	println('   > node modules install')
	process.execute_silent(script_install) or {
		return error('cannot install node modules for ${name}.\n$err')
	}

	//lets upgrade for tailwind
	// mut ri := texttools.regex_instructions_new()
	// instr := [
	// 	'whitespace-no-wrap:whitespace-nowrap',
	// 	'flex-no-wrap:flex-nowrap',
	// 	'col-gap-:gap-x-',
	// 	'row-gap-:gap-y-'
	// ]
	// ri.add(instr) or { panic(err) }
	// mut count := 0
	// count += ri.replace_in_dir(path:"$path/src",extensions:["html","vue"],dryrun:true) or { panic(err) }
	// if os.exists("$path/tailwindui"){
	// 	count += ri.replace_in_dir(path:"$path/tailwindui",extensions:["html","vue"],dryrun:true) or { panic(err) }
	// 	if count>0{
	// 		println(" - TAILWIND UPGRADE WITH $count CHANGES for $path")
	// 	}
	// }

	// only require threebot_data in case of gridsome website
	if os.exists('$path/gridsome.config.js'){
		mut datarepo := gt.repo_get(name: 'threefold_data') or {
			return error('ERROR: cannot get repo:$err')
		}
	
		for x in ['blog', 'person', 'news', 'project'] {
			if os.exists('$path/content') {
				process.execute_silent('rm -rf $path/content/$x\n') ?
				os.symlink('$datarepo.path_get()/content/$x',
					'$path/content/$x') or {
					return error('Cannot link $x from data path to path.\n$err')
				}
			}
		}
	}

	os.write_file('$path/.installed', '') or {
		return error('cannot write to $path/.installed\n$err')
	}
}

pub fn wiki_install(site_conf publisher_config.SiteConfig, conf &publisher_config.ConfigRoot) ? {
	// name := site_conf.reponame
	// base := conf.publish.paths.base
	// codepath := conf.publish.paths.code
	// multibranch := conf.publish.multibranch
	mut path := site_conf.path
	println(' - install wiki on $path')

}
