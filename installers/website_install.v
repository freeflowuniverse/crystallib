module installers

import os
import publisher_config
import process
import gittools
import texttools
import installers.nodejs

// is the one coming from command line
pub fn web(doreset bool, clean bool) ? {
	println(' - install websystem: doreset:$doreset clean:$clean')
	// println('INSTALLER:')
	if doreset {
		println(' - reset the full system')
		reset() or { return error(' ** ERROR: cannot reset. Error was:\n$err') }
	}
	base() or { return error(' ** ERROR: cannot prepare system. Error was:\n$err') }

	// sites_download( true) or {
	// 	return error(' ** ERROR: cannot get web & wiki sites. Error was:\n$err')
	// }
	mut n := nodejs.get() or { return error(' ** ERROR: cannot install nodejs. Error was:\n$err') }
	n.install() or { return error(' ** ERROR: cannot install nodejs. Error was:\n$err') }

	if clean {
		sites_cleanup([]) or { return error(' ** ERROR: cannot cleanup sites. Error was:\n$err') }
	}

	// make sure the config we are working with is refelected in ~/.publisher/config
	// update_config() or { return error(' ** ERROR: cannot copy config files to ~publisher/config. Error was:\n$err') }

	mut gt := gittools.get()?

	gt.repo_get_from_url(url: 'https://github.com/threefoldfoundation/threefold_data')?

	sites_install([]) or { return error(' ** ERROR: cannot install sites. Error was:\n$err') }

	println(' - websites installed')
}

// Initialize (load wikis) only once when server starts
pub fn website_install(names []string, first bool) ? {
	mut conf := publisher_config.get()?
	for mut site in conf.sites_get(names) {
		mut repo := site.repo_get()
		base := conf.publish.paths.base
		nodejspath := conf.nodejs.path
		mut path := site.path.path

		println(' - install website $site.name on $path')

		mut gt := gittools.get()?

		if conf.publish.reset || site.reset {
			script6 := '
			#!/usr/bin/env bash
			cd $path

			rm -rf modules
			rm -f .installed
			rm -f src/errors.md
			'
			println('   > reset')
			process.execute_silent(script6) or {
				return error('cannot install node modules for ${repo.addr.name}.\n$err')
			}
			repo.remove_changes()?
		}

		if conf.publish.pull || site.pull {
			repo.pull()?
		}

		mut nvm_line := ''
		if conf.nodejs.nvm {
			nvm_line = 'source $base/nvm.sh && nvm use --lts && export PATH=$nodejspath/bin:\$PATH'
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

		mkdir -p $conf.publish.paths.publish/www_$site.name
		rsync -ra --delete $path/dist/ $conf.publish.paths.publish/www_$site.name/

		cd $path/dist

		#echo go to http://localhost:9999/
		#python3 -m http.server 9999

		'

		package_json := '
		{
			"name": "$site.name",
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
				"autoprefixer": "^10.3.3",
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
				"postcss": "^8.3.6",
				"sass-loader": "^10.0.2",
				"tailwindcss": "^2.2.9",
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
			return error('cannot write to $path/install\n$err')
		}
		os.write_file('$path/run', texttools.dedent(script_run)) or {
			return error('cannot write to $path/run\n$err')
		}
		os.write_file('$path/build', texttools.dedent(script_build)) or {
			return error('cannot write to $path/build\n$err')
		}

		os.write_file('$path/package.json', texttools.dedent(package_json)) or {
			return error('cannot write to $path/package.json\n$err')
		}

		os.chmod('$path/install', 0o700)?
		os.chmod('$path/run', 0o700)?
		os.chmod('$path/build', 0o700)?

		if os.exists('$path/.installed') {
			return
		}

		println('   > node modules install')
		process.execute_silent(script_install) or {
			return error('cannot install node modules for ${repo.addr.name}.\n$err')
		}

		// lets upgrade for tailwind
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
		if os.exists('$path/gridsome.config.js') {
			mut datarepo := gt.repo_get(name: 'threefold_data') or {
				return error('ERROR: cannot get repo:$err')
			}

			for x in ['blog', 'person', 'news', 'project'] {
				if os.exists('$path/content') {
					process.execute_silent('rm -rf $path/content/$x\n')?
					os.symlink('$datarepo.path()/content/$x', '$path/content/$x') or {
						return error('Cannot link $x from data path to path.\n$err')
					}
				}
			}
		}

		os.write_file('$path/.installed', '') or {
			return error('cannot write to $path/.installed\n$err')
		}
	}
}

pub fn wiki_install(names []string) ? {
	mut conf := publisher_config.get()?
	println(conf.sites_wiki_get(names))
	for mut site in conf.sites_wiki_get(names) {
		mut repo := site.repo_get()
		println(' - install wiki $site.name on $site.path.path')

		if conf.publish.reset || site.reset {
			repo.remove_changes()?
			println('   > reset')
		}

		if conf.publish.pull || site.pull {
			repo.pull()?
			println('   > pull wiki: $site.name')
		}
	}
}
