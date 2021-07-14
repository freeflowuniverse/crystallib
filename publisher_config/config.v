module publisher_config

import os
// import gittools
import json
import despiegk.crystallib.gittools

// load the initial config from filesystem
fn config_load() ?ConfigRoot {
	mut config := ConfigRoot{}

	// Load Publish config
	if os.exists('config.json') {
		println(' - Found config file for publish tools.')
		txt := os.read_file('config.json') ?
		config.publish = json.decode(PublishConfig, txt) ?
	} else {
		println(' - Not Found config file for publish tools. Default values applied')
		config.publish = PublishConfig{
			reset: false
			pull: false
			debug: true
			redis: false
			paths: Paths{
				base: '$os.home_dir()/.publisher'
				code: '$os.home_dir()/codewww'
				codewiki: '$os.home_dir()/codewiki'
			}
		}
		
	}
	if config.publish.paths.base == "" {
		config.publish.paths.base = '$os.home_dir()/.publisher'
	}
	if config.publish.paths.code == "" {
		config.publish.paths.code = '$os.home_dir()/codewww'
	}
	if config.publish.paths.codewiki == "" {
		config.publish.paths.codewiki = '$os.home_dir()/codewiki'
	}
	if config.publish.paths.publish == "" {
		config.publish.paths.publish = '$config.publish.paths.base/publish'
	}

	// Make sure that all dirs existed/created

	if !os.exists(config.publish.paths.base) {
		os.mkdir(config.publish.paths.base) or { return error("Cannot create path for publisher: $err") }
	}

	if !os.exists(config.publish.paths.code) {
	
		os.mkdir(config.publish.paths.code) or { return error("Cannot create path for publisher: $err") }
	}

	if !os.exists(config.publish.paths.codewiki) {
		os.mkdir(config.publish.paths.codewiki) or { return error("Cannot create path for publisher: $err") }
	}

	// Load nodejs config
	if os.exists('nodejs.json') {
		println(' - Found config file for NodeJS.')
		txt := os.read_file('nodejs.json') ?
		config.nodejs = json.decode(NodejsConfig, txt) ?
	} else {
		println(' - Not Found config file for NodeJS. Default values applied')
		config.nodejs = NodejsConfig{
			version: 'lts'
		}
	}
	config.init_nodejs() // Init nodejs configurations

	config.web_hostnames = false

	// Load Static config
	staticfiles_config(mut &config)

	// Load Site & Group config files
	mut sites_config_files := []string{}
	mut groups_config_files := []string{}

	current_dir := '.'
	mut files := os.ls(current_dir) or { return error("Cannot load config files in current dir, $err") }
	for file in files {
		if (file.starts_with('site_') && file.ends_with('.json')) || file == 'sites.json' {
			sites_config_files << file
		}
		if file.starts_with('groups_') && file.ends_with('.json'){
			groups_config_files << file
		}
	}
	for site_file in sites_config_files {
		println(' - found $site_file as a config file for sites.')
		txt := os.read_file(site_file) ?
		config.sites << json.decode([]SiteConfig, txt) ?
	}

	// Load Groups
	for group_file in groups_config_files {
		println(' - found $group_file as a config file for group.')
		txt := os.read_file(group_file) ?
		config.groups << json.decode([]UserGroup, txt) ?
	}

	mut gt := gittools.new(config.publish.paths.code) or { return error('cannot load gittools:$err') }

	for mut site in config.sites{
		config.process_site_repo( mut &gt, mut &site)?
	}

	return config
}


fn (mut config ConfigRoot) process_site_repo(mut gt gittools.GitStructure, mut site SiteConfig) ? {

	if site.state != SiteState.init{
		println(site)
		panic("should not get here, site need to be in state init.")
	}

	mut site_path := ""

	if site.path_fs!= "" {
		//this is the path on the filesystem
		site_path = site.path_fs
	}else{
		println(' - get:$site.url')
		mut repo := gt.repo_get_from_url(url: site.url, pull: site.pull, reset: site.reset, branch: site.branch) or {
			return error(' - ERROR: could not download site $site.url, do you have rights?\n$err\n$site')
		}
		site_path = "$repo.path/$site.path"
	}

	site_config := os.join_path(site_path, 'wikiconfig.json')

	if ! os.exists(site_config) {
		return error("cannot find config file for repo in $site_config")
	}

	//DONT DO YET, NEED TO FIGURE OUT HOW TO DEAL WITH DEPENDENCIES ... (kristof)
		
	// content := os.read_file(site_config) or {
	// 	return error('Failed to load json $site_config')
	// }
	// //local config as defined in repo
	// repoconfig := json.decode(SiteConfigLocal, content) or {
	// 	return error('Failed to decode json $site_config')
	// }

	// if site.name == "" {
	// 	site.name = repoconfig.name
	// }
	// if site.descr=="" {
	// 	site.descr = repoconfig.descr
	// }

	// site.cat = repoconfig.cat

	// for dep in repoconfig.depends{

	// 	if config.site_exists_from_dep(dep){
	// 		if site.branch.to_lower() != dep.branch.to_lower(){
	// 			return error("no support yet for multiple branches in 1 publishtools instance: $site\n$depconfig")
	// 		}
	// 	}else{
	// 		mut repo := gt.repo_get_from_url(url: dep.url, pull: site.pull, reset: site.reset, branch: dep.branch) or {
	// 			return error(' - ERROR: could not download site $dep.url, do you have rights?\n$err\n$dep')
	// 		}

	// 		mut site_dep := SiteConfig{}
	// 		site_dep.path = dep.path
	// 		site_dep.path_fs = dep.path_fs
	// 		site_dep.url = dep.url
	// 		site_dep.branch = dep.branch
	// 		site_dep.pull = site.pull
	// 		site_dep.reset = site.reset
	// 		config.sites << site_dep
	// 		//to process recursive all sub paths				
	// 		config.process_site_repo(mut &gt, mut &site_dep)?
	// 	}
	// }

	site.state = SiteState.loaded
}


// to create singleton
const gconf = config_load() or { panic(err) }

pub fn get() ConfigRoot {
	return publisher_config.gconf
}
