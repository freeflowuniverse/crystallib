module publisher_config

import os
import despiegk.crystallib.texttools
import json
import despiegk.crystallib.gittools

// fn config_dir_find(path string) string{


// }

// load the initial config from filesystem
fn config_load() ?ConfigRoot {
	mut config := ConfigRoot{}

	envs := os.environ()

	if "PUBSITE" in envs{
		mut gt2 := gittools.new("",false) ?
		url := envs["PUBSITE"]
		println(" - get git repo to fetch config for publ tools: $url")
		r := gt2.repo_get_from_url(url:url,pull:true)?
		// println(r.addr)
		// println(r.path_content_get())
		// panic("s")
		println(" - changedir for config: $r.path_content_get()")
		os.chdir(r.path_content_get())
	}
	
	
	// Load Site & Group config files
	mut sites_config_files := []string{}
	mut groups_config_files := []string{}

	current_dir := '.'
	mut files := os.ls(current_dir) or {
		return error('Cannot load config files in current dir, $err')
	}
	for file in files {
		if file.starts_with('site_') && file.ends_with('.json') {
			sites_config_files << file
		}
		if file.starts_with('groups_') && file.ends_with('.json') {
			groups_config_files << file
		}
	}

	
	if sites_config_files.len < 1{
		curdir := os.getwd()
		return error("cannot find site files in current dir: $curdir, site files start with site_")
	}

	//will check if there are site_... files, if not is error


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
		}
	}
	if config.publish.paths.base == '' {
		if 'DIR_BASE' in os.environ() {
			config.publish.paths.base = os.environ()['DIR_BASE']
		} else {
			config.publish.paths.base = '$os.home_dir()/.publisher'
		}
	}
	if config.publish.paths.code == '' {
		if 'DIR_CODE' in os.environ() {
			config.publish.paths.code = os.environ()['DIR_CODE']
		} else {
			config.publish.paths.code = '$os.home_dir()/code'
		}
	}
	if config.publish.paths.codewiki == '' {
		if 'DIR_CODEWIKI' in os.environ() {
			config.publish.paths.codewiki = os.environ()['DIR_CODEWIKI']
		} else {
			config.publish.paths.codewiki = '$os.home_dir()/codewiki'
		}
	}
	if config.publish.paths.publish == '' {
		config.publish.paths.publish = '$config.publish.paths.base/publish'
	}

	// Make sure that all dirs existed/created
	for dest in [config.publish.paths.base, config.publish.paths.code, config.publish.paths.codewiki] {
		if !os.exists(dest) {
			os.mkdir_all(dest) or { return error('Cannot create path $dest for publisher: $err') }
		}
	}

	//DEFAULT VALUES
	config.nodejs = NodejsConfig{
		version: NodejsCat.lts
		// means we don't install in platform
		nvm: true
	}

	// Load nodejs config
	if os.exists('nodejs.json') {
		println(' - Found config file for NodeJS.')
		txt := os.read_file('nodejs.json') ?
		fsnodejs := json.decode(NodejsConfigFS, txt) ?
		if fsnodejs.version == 'lts' {
			config.nodejs.version = NodejsCat.lts
		} else {
			config.nodejs.version = NodejsCat.latest
		}
		config.nodejs.nvm = fsnodejs.nvm
	} else {
		println(' - Not Found config file for NodeJS. Default values applied')
	}
	config.init_nodejs() // Init nodejs configurations

	config.web_hostnames = false

	// Load Static config
	staticfiles_config(mut &config)


	for site_file in sites_config_files {
		println(' - found $site_file as a config file for sites.')
		txt := os.read_file(site_file) ?
		// mut site_in := json.decode(SiteConfig, txt) ?
		mut site_in := json.decode(SiteConfig, txt) or { panic(err) }
		if site_in.name == '' {
			panic('site name should not be empty. Prob means error in json.\n$txt')
		}
		// make sure we normalize the name
		site_in.name = texttools.name_fix(site_in.name)
		// site_in.configroot = &config
		config.sites << site_in
	}

	// Load Groups
	for group_file in groups_config_files {
		println(' - found $group_file as a config file for group.')
		txt := os.read_file(group_file) ?
		config.groups << json.decode([]UserGroup, txt) ?
	}

	return config
}

pub fn (mut site SiteConfig) load(configroot ConfigRoot) ? {
	if site.state == SiteState.loaded {
		return
	}

	// println(" - process site: $site.name")

	mut config := configroot

	// just get instance of the gittools
	mut gt := gittools.new(config.publish.paths.code, config.publish.multibranch) ?

	if site.state != SiteState.init {
		panic('should not get here, bug, site need to be in state init.')
	}

	if site.fs_path != '' {
		// this is the path on the filesystem	
		site.path = os.real_path(site.fs_path)
	} else {
		println(' - get:$site.git_url')
		mut repo := gt.repo_get_from_url(url: site.git_url, pull: site.pull, reset: site.reset) or {
			return error(' - ERROR: could not download site $site.git_url\n$err\n$site')
		}
		// println(' - get git addr obj:$repo.addr')
		site.fs_path = ''
		site.path = os.join_path(repo.path_get(), repo.addr.path)
		site.reponame = repo.addr.name
	}
	if !os.exists(site.path) || site.path == '' {
		println('- Error Cannot find `$site.path` for \n$site\nin process site repo. Creating `$site.path`')
		return error(' - ERROR: could not find source path:$site.path for\nsite $site.git_url\n$site')
	}

	toremoves := [os.join_path(site.path, 'index.html'), os.join_path(site.path, 'wikiconfig.json')]
	for toremove in toremoves {
		if os.exists(toremove) {
			os.rm(toremove) or {
				return error('could not remove: $toremove for process_site_repo. \n$err')
			}
		}
	}

	// println(site)

	site.state = SiteState.loaded

	// DONT DO YET, NEED TO FIGURE OUT HOW TO DEAL WITH DEPENDENCIES ... (kristof)

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
	// 		mut repo := gt.repo_get_from_url(url: dep.git_url, pull: site.pull, reset: site.reset, branch: dep.branch) or {
	// 			return error(' - ERROR: could not download site $dep.git_url, do you have rights?\n$err\n$dep')
	// 		}

	// 		mut site_dep := SiteConfig{}
	// 		site_dep.path = dep.path
	// 		site_dep.fs_path = dep.fs_path
	// 		site_dep.git_url = dep.git_url
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
const gconf = config_load() or {
	println('Cannot load configuraton for publish tools.\n$err')
	println('===ERROR===')
	exit(1)
}

pub fn get() &ConfigRoot {
	return &publisher_config.gconf
}
