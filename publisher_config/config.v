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
		config.sites = []SiteConfig{}
		config.sites << json.decode([]SiteConfig, txt) ?
	}

	// Load Groups
	for group_file in groups_config_files {
		println(' - found $group_file as a config file for group.')
		txt := os.read_file(group_file) ?
		config.groups = []UserGroup{}
		config.groups << json.decode([]UserGroup, txt) ?
	}

	mut gt := gittools.new(config.publish.paths.code) or { return error('cannot load gittools:$err') }

	for site in config.sites{

	
		if site.cat == publisher_config.SiteCat.web {
			continue
		}
		if site.cat == publisher_config.SiteCat.data{
			continue
		}

		mut pathnew := ""

		if site.path_fs!= "" {
			//this is the path on the filesystem
			pathnew = site.path_fs
		}else{
			println(' - get:$site.url')
			mut repo := gt.repo_get_from_url(url: site.url, pull: site.pull, reset: site.reset, branch: site.branch) or {
				return error(' - ERROR: could not download site $site.url, do you have rights?\n$err\n$site')
			}
		
			pathnew = "$repo.path/$site.path"
		}


		process_site(mut &config, site, pathnew)?

		panic("AA")

	}



	return config
}


fn process_site(mut config ConfigRoot,site SiteConfig, path string) ? {
		
		pathnew2 := os.join_path(path, 'wikiconfig.json')

		if os.exists(pathnew2) {
			
			content := os.read_file(pathnew2) or {
				return error('Failed to load json ${os.join_path(pathnew, 'wikiconfig.json')}')
			}
			repoconfig := json.decode(SiteConfigLocal, content) or {
				return error('Failed to decode json ${os.join_path(pathnew, 'wikiconfig.json')}')
			}

			//check dependencies
			for dep in repoconfig{
				mut repo := gt.repo_get_from_url(url: repoconfig.url, pull: site.pull, reset: site.reset, branch: repoconfig.branch) or {
					return error(' - ERROR: could not download site $repoconfig.url, do you have rights?\n$err\n$repoconfig')
				}
			}

		}else{
			return error("Could not find wikiconfig.json on $pathnew2 for $site.url")
		}

}


// to create singleton
const gconf = config_load() or { panic(err) }

pub fn get() ?ConfigRoot {
	return publisher_config.gconf
}
