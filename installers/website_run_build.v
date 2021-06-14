module installers

import despiegk.crystallib.myconfig
import despiegk.crystallib.process
import despiegk.crystallib.gittools
import despiegk.crystallib.publishermod
import cli
import os

fn website_conf_repo_get(cmd &cli.Command, mut conf myconfig.ConfigRoot) ?&gittools.GitRepo {
	flags := cmd.flags.get_all_found()
	mut name := flags.get_string('repo') or { '' }

	mut res := []string{}
	for mut site in conf.sites_get() {
		if site.cat == myconfig.SiteCat.web {
			if site.name.contains(name) {
				res << site.reponame()
			}
		}
	}

	if res.len == 1 {
		name = res[0]
	} else if res.len > 1 {
		sites_list(cmd) ?
		return error('Found more than 1 or website with name: $name')
	} else {
		sites_list(cmd) ?
		return error('Cannot find website with name: $name')
	}

	conf.nodejs_check()

	mut gt := gittools.new(conf.paths.code) or { return error('ERROR: cannot load gittools:$err') }
	reponame := conf.reponame(name) ?
	mut repo := gt.repo_get(name: reponame) or {
		return error('ERROR: cannot find repo: $name\n$err')
	}

	return repo
}

pub fn website_develop(cmd &cli.Command, mut cfg myconfig.ConfigRoot) ? {
	repo := website_conf_repo_get(cmd, mut cfg) ?

	println(' - start website: $repo.path')
	process.execute_interactive('$repo.path/run.sh') ?
}

fn rewrite_config(path string, shortname string) {
	println(' >> REWRITE CONFIG: $path $shortname')
}

pub fn website_build(cmd &cli.Command) ? {
	// save new config file
	myconfig.save('') ?

	mut arg := ''
	mut use_prefix := false

	arg = cmd.flags.get_string('repo') or { '' }
	use_prefix = cmd.flags.get_bool('pathprefix') or { false }

	mut conf := myconfig.get() ?
	mut sites := conf.sites_get()

	if arg.len == 0 {
		println('- Flatten all wikis')
		mut publ := publishermod.new(conf.paths.code) or { panic('cannot init publisher. $err') }
		publ.flatten() ?
		println(' - build all websites')
		mut gt := gittools.new(conf.paths.code) or {
			return error('ERROR: cannot load gittools:$err')
		}
		for site in sites {
			if site.cat == myconfig.SiteCat.web {
				mut repo2 := gt.repo_get(name: site.name) or {
					return error('ERROR: cannot find repo: $site.name\n$err')
				}
				println(' - build website: $repo2.path')
				mut isgridsome := true
				mut vuejs := true

				if !os.exists('$repo2.path/gridsome.config.js'){
					isgridsome = false
				}

				if !os.exists('$repo2.path/vue.config.js'){
					vuejs = false
				}


				if isgridsome{
					process.execute_stdout('sed -i "s/pathPrefix.*//" $repo2.path/gridsome.config.js') ?
				}else if vuejs{
					process.execute_stdout('sed -i "s/publicPath:.*//" $repo2.path/vue.config.js') ?
				}

				if use_prefix {
					if isgridsome{
						process.execute_stdout('sed -i "s/plugins: \\\[/pathPrefix: \\\"$site.shortname\\\",\\n\\tplugins: \\\[/g" $repo2.path/gridsome.config.js') ?
					}else if vuejs{
						process.execute_stdout('sed -i "s/configureWebpack:: \\\{/publicPath: \\\"$site.shortname\\\",\\n\\configureWebpack:: \\\{/g" $repo2.path/vue.config.js') ?
					}
					
				}

				process.execute_stdout('$repo2.path/build.sh') or {
					if isgridsome{
						process.execute_stdout('cd $repo2.path/ && git checkout gridsome.config.js') ?
					}else if vuejs{
						process.execute_stdout('cd $repo2.path/ && git checkout vue.config.js') ?
					}
				}

				if isgridsome{
					process.execute_stdout('cd $repo2.path/ && git checkout gridsome.config.js') ?
				}else if vuejs{
					process.execute_stdout('cd $repo2.path/ && git checkout vue.config.js') ?
				}
			}
		}
	} else {
		repo := website_conf_repo_get(cmd, mut &conf) ?
		// be careful process stops after interactive execute
		// process.execute_interactive('$repo.path/build.sh') ?
		for site in sites {
			if site.name == repo.addr.name {
				println(' - build website: $repo.path')
				
				mut isgridsome := true
				mut vuejs := true

				if !os.exists('$repo.path/gridsome.config.js'){
					isgridsome = false
				}

				if !os.exists('$repo.path/vue.config.js'){
					vuejs = false
				}

				if isgridsome{
					process.execute_stdout('sed -i "s/pathPrefix.*//" $repo.path/gridsome.config.js') ?
				}else if vuejs{
					process.execute_stdout('sed -i "s/publicPath:.*//" $repo.path/vue.config.js') ?
				}

				if use_prefix {
					if isgridsome{
						process.execute_stdout('sed -i "s/plugins: \\\[/pathPrefix: \\\"$site.shortname\\\",\\n\\tplugins: \\\[/g" $repo.path/gridsome.config.js') ?
					}else if vuejs{
						process.execute_stdout('sed -i "s/configureWebpack: {/publicPath: \\\"$site.shortname\\\",\\n\configureWebpack: {/g" $repo.path/vue.config.js') ?
					}
					
				}

				process.execute_stdout('$repo.path/build.sh') ?
				
				if isgridsome{
					process.execute_stdout('cd $repo.path/ && git checkout gridsome.config.js') ?
				}else if vuejs{
					process.execute_stdout('cd $repo.path/ && git checkout vue.config.js') ?
				}
				break
			}
		}
	}
}
