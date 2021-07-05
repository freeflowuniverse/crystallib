module publishconfig

import os
// import gittools

import json

// load the initial config from filesystem
fn config_load() ?ConfigRoot {
	mut config := ConfigRoot{}

	// Load Publish Config
	if os.exists('config.json') {
		println(' - Found config file for publish tools.')
		txt := os.read_file('config.json') ?
		config.publishconfig = json.decode(PublishConfig, txt) ?
	}else{
		println(' - Not Found config file for publish tools. Default values applied')
		config.publishconfig = PublishConfig{
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
		config.publishconfig.paths.publish = '$config.publishconfig.paths.base/publish'
	}

	// Make sure that all dirs existed/created 
	if !os.exists(config.publishconfig.paths.code) {
		os.mkdir(config.publishconfig.paths.code) or { panic(err) }
	}

	if !os.exists(config.publishconfig.paths.codewiki) {
		os.mkdir(config.publishconfig.paths.codewiki) or { panic(err) }
	}

	// Load nodejs config
	mut nodejsconfig := NodejsConfig{
		version: NodejsVersion{
			cat: NodejsVersionEnum.lts
		}
	}
	config.nodejs = nodejsconfig
	config.init_nodejs() // Init nodejs configurations

	// config.web_hostnames = false // This key commented in the struct

	// Load Static confif
	staticfiles_config(mut &config)

	// Load Site Config -- TODO: take variable site config file name
	if os.exists('sites.json') {
		println(' - Found config files for Sites.')
		txt := os.read_file('sites.json') ?
		config.sites = []SiteConfig{}
		config.sites = json.decode([]SiteConfig, txt) ?
	}

	return config
}

//to create singleton
const gconf = config_load() or { panic(err) }

pub fn get() ?ConfigRoot {
	return publishconfig.gconf
}

