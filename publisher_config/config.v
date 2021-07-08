module publisher_config

import os
// import gittools
import json

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
		config.publish.paths.publish = '$config.publish.paths.base/publish'
	}

	// Make sure that all dirs existed/created
	if !os.exists(config.publish.paths.code) {
		os.mkdir(config.publish.paths.code) or { panic(err) }
	}

	if !os.exists(config.publish.paths.codewiki) {
		os.mkdir(config.publish.paths.codewiki) or { panic(err) }
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

	// config.web_hostnames = false // This key commented in the struct

	// Load Static config
	staticfiles_config(mut &config)

	// Load Site config
	mut sites_config_files := []string{}
	current_dir := '.'
	mut files := os.ls(current_dir) or { panic(err) }
	for file in files {
		if (file.starts_with('site_') && file.ends_with('.json')) || file == 'sites.json' {
			sites_config_files << file
		}
	}
	for site_file in sites_config_files {
		println(' - Found $site_file as a config file for Sites.')
		txt := os.read_file(site_file) ?
		config.sites = []SiteConfig{}
		config.sites << json.decode([]SiteConfig, txt) ?
	}

	return config
}

// to create singleton
const gconf = config_load() or { panic(err) }

pub fn get() ?ConfigRoot {
	return publisher_config.gconf
}
