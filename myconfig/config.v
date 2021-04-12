module myconfig

import os
import gittools
import myconfig
import json

// get the initial config 
fn initial() ConfigRoot {
	mut c := ConfigRoot{}
	c.paths.base = '$os.home_dir()/.publisher'
	c.paths.publish = '$c.paths.base/publish'
	c.paths.code = '$os.home_dir()/codewww'
	if !os.exists(c.paths.code) {
		os.mkdir(c.paths.code) or { panic(err) }
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
	c := get(true) ?
	txt := json.encode_pretty(c.sites)
	if path2 == '' {
		path2 = '~/.publisher/sites.json'
	}
	path2 = os.real_path(path2).replace('~', os.home_dir())
	os.write_file(path2, txt) ?
}

pub fn get(web bool) ?ConfigRoot {
	mut conf := initial()
	if os.exists('sites.json') {
		// println(' - Found config files for sites in local dir.')
		txt := os.read_file('sites.json') ?
		conf.sites = []SiteConfig{}
		conf.sites = json.decode([]SiteConfig, txt) ?
	}
	mut gt := gittools.new(conf.paths.code) or { return error('ERROR: cannot load gittools:$err') }
	for mut site in conf.sites {
		// println(' >> $site.name')
		if !web && site.cat == myconfig.SiteCat.web {
			continue
		}
		if site.path_code == '' {
			// println(' >> $site.reponame() ')
			mut repo := gt.repo_get(name: site.reponame()) or {
				// return error('ERROR: cannot find repo: $site.name\n$err')
				// do NOTHING, just ignore the site to work with
				// print(err)
				// println(' - WARNING: did not find site: $site.name, $err')				
				continue
			}
			site.path_code = repo.path_get()
		}
	}
	return conf
}
