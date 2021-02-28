module installers

import myconfig
import process
import gittools
import cli
import os
import json

pub struct Group{
	pub mut:
		users []string
		groups []string
}

fn website_conf_repo_get(cmd &cli.Command) ?(myconfig.ConfigRoot, &gittools.GitRepo) {
	mut name := ''
	mut conf := myconfig.get(true) ?

	for flag in cmd.flags {
		if flag.name == 'repo' {
			if flag.value.len > 0 {
				name = flag.value[0]
			}
		}
	}

	if name == '' {
		return error("please specify repo name with '-r name', can be part of name")
	}

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

	mut gt := gittools.new(conf.paths.code) or { return error('ERROR: cannot load gittools:$err') }
	reponame := conf.reponame(name) ?
	mut repo := gt.repo_get(name: reponame) or {
		return error('ERROR: cannot find repo: $name\n$err')
	}

	return conf, repo
}

pub fn website_develop(cmd &cli.Command) ? {
	_, repo := website_conf_repo_get(cmd) ?
	println(' - start website: $repo.path')
	process.execute_interactive('$repo.path/run.sh') ?
}

pub fn website_build(cmd &cli.Command) ? {
	mut arg := false
	for flag in cmd.flags {
		if flag.name == 'repo' {
			if flag.value.len > 0 {
				arg = true
			}
		}
	}

	mut conf := myconfig.get(true) ?
	mut sites := conf.sites_get()
	// groups
	os.write_file('$conf.paths.publish/.groups.json', json.encode(map{'test': Group{}})) ?
	if !arg {
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
				process.execute_stdout('$repo2.path/build.sh') ?
				os.write_file('$conf.paths.publish/$site.name/.domains.json', json.encode(map{
					'domains': site.domains
				})) ?

				os.write_file('$conf.paths.publish/$site.name/.repo', '$repo2.addr.name') ?
				
				os.write_file('$conf.paths.publish/$site.name/.acls.json', json.encode(map{
					'users': []string{},
					'groups': []string{}
				})) ?
			
			}
		}
	} else {
		_, repo := website_conf_repo_get(cmd) ?
		println(' - build website: $repo.path')
		// be careful process stops after interactive execute
		// process.execute_interactive('$repo.path/build.sh') ?
		for site in sites {
			if site.name == repo.addr.name {
				println(' - build website: $repo.path')
				process.execute_stdout('$repo.path/build.sh') ?
				os.write_file('$conf.paths.publish/$site.name/.domains.json', json.encode(map{
					'domains': site.domains
				})) ?

				os.write_file('$conf.paths.publish/$site.name/.repo', '$repo.addr.name') ?

				os.write_file('$conf.paths.publish/$site.name/.acls.json', json.encode(map{
					'users': []string{},
					'groups': []string{}
				})) ?

				break
			}
		}
	}
}
