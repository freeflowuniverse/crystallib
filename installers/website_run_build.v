module installers

import publisher.config
import process
// import pathlib
import json
import os

pub fn website_develop(names []string) ? {
	mut conf := config.get()?
	for mut sc in conf.sites_get(names) {
		mut repo := sc.repo_get()
		println(' - start website: $repo.path()')
		process.execute_interactive('$repo.path()/run')?
	}
}

fn rewrite_config(path string, shortname string) {
	println(' >> REWRITE CONFIG: $path $shortname')
}

pub fn website_build(use_prefix bool, names []string) ? {
	// save new config file
	// config.save('') ?
	mut conf := config.get()?
	for mut sc in conf.sites_get(names) {
		mut repo := sc.repo_get()
		if sc.cat != config.SiteCat.web {
			continue
		}
		println(' - build website: $repo.path_get()')
		mut isgridsome := true
		mut vuejs := true

		if !os.exists('$repo.path_get()/gridsome.config.js') {
			isgridsome = false
		}

		if !os.exists('$repo.path_get()/vue.config.js') {
			vuejs = false
		}

		if isgridsome {
			process.execute_stdout('sed -i "s/pathPrefix.*//" $repo.path_get()/gridsome.config.js')?
		} else if vuejs {
			process.execute_stdout('sed -i "s/publicPath:.*//" $repo.path_get()/vue.config.js')?
		}

		// if use_prefix {
		// 	if isgridsome {
		// 		process.execute_stdout("sed -i "s/plugins: \\\[/pathPrefix: \\\"$sc.prefix\\\",\\n\\tplugins: \\\[/g" $repo.path_get()/gridsome.config.js")?
		// 	} else if vuejs {
		// 		process.execute_stdout("sed -i "s/configureWebpack: {/publicPath: \\\"\\/$sc.prefix\\\",\\n\configureWebpack: {/g" $repo.path_get()/vue.config.js")?
		// 	}
		// }

		process.execute_stdout('$repo.path_get()/build') or {
			if isgridsome {
				process.execute_stdout('cd $repo.path_get()/ && git checkout gridsome.config.js')?
			} else if vuejs {
				process.execute_stdout('cd $repo.path_get()/ && git checkout vue.config.js')?
			}
		}

		if isgridsome {
			process.execute_stdout('cd $repo.path_get()/ && git checkout gridsome.config.js')?
		} else if vuejs {
			process.execute_stdout('cd $repo.path_get()/ && git checkout vue.config.js')?
		}
		// Write config files
		println('-  Write config file for site: $sc.name to $conf.publish.paths.publish')
		the_config := json.encode_pretty(sc.raw)
		os.write_file('$conf.publish.paths.publish/config_site_' + sc.name + '.json',
			the_config)?
	}
}
