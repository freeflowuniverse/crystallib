module publishconfig

import os
// import gittools

import json

// load the initial config from filesystem
fn config_load() ?ConfigRoot {
	mut c := ConfigRoot{}

	if os.exists('config.json') {
		println(' - Found config file for publish tools.')
		txt := os.read_file('config.json') ?
		conf.sites = json.decode(PublishConfig, txt) ?
	}


	c.paths.base = '$os.home_dir()/.publisher'
	c.paths.publish = '$c.paths.base/publish'
	c.paths.code = '$os.home_dir()/codewww'
	c.paths.codewiki = '$os.home_dir()/codewiki'

	if !os.exists(c.paths.code) {
		os.mkdir(c.paths.code) or { panic(err) }
	}

	if !os.exists(c.paths.codewiki) {
		os.mkdir(c.paths.codewiki) or { panic(err) }
	}

	mut nodejsconfig := NodejsConfig{
		version: NodejsVersion{
			cat: NodejsVersionEnum.lts
		}
	}
	c.nodejs = nodejsconfig

	c.reset = false
	c.pull = false
	c.debug = true
	c.redis = false
	c.web_hostnames = false

	c.init()



	// add the site configurations to it
	site_config(mut &c)
	staticfiles_config(mut &c)

	if os.exists('sites.json') {
		// println(' - Found config files for sites in local dir.')
		txt := os.read_file('sites.json') ?
		conf.sites = []SiteConfig{}
		conf.sites = json.decode([]SiteConfig, txt) ?
	}


	return c
}


//to create singleton
const gconf = config_load() or { panic(err) }

pub fn get() ?ConfigRoot {
	return publishconfig.gconf
}

