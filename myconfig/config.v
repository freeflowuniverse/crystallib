module myconfig

import os
// import gittools
import despiegk.crystallib.myconfig
import json

// get the initial config
fn initial() ConfigRoot {
	mut c := ConfigRoot{}
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
			cat: myconfig.NodejsVersionEnum.lts
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

	return c
}

pub fn save(path string) ? {
	mut path2 := path
	c := get() ?
	txt := json.encode_pretty(c.sites)
	if path2 == '' {
		path2 = '~/.publisher/sites.json'
	}
	path2 = os.real_path(path2).replace('~', os.home_dir())
	println(' - write config file on $path2')
	os.write_file(path2, txt) ?
}

pub fn get() ?ConfigRoot {
	mut conf := initial()
	if os.exists('sites.json') {
		// println(' - Found config files for sites in local dir.')
		txt := os.read_file('sites.json') ?
		conf.sites = []SiteConfig{}
		conf.sites = json.decode([]SiteConfig, txt) ?
	}
	return conf
}

pub fn (mut cfg ConfigRoot) nodejs_check(){
	if ! os.exists(cfg.nodejs.path){
		println("ERROR\ncannot find nodejs, reinstall using 'publishtools install -r'")
		exit(1)
	}
}
