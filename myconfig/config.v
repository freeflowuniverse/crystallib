module myconfig

import os
import gittools

fn get2() ConfigRoot {
	mut c := ConfigRoot{}
	c.paths.base = '$os.home_dir()/.publisher'
	c.paths.publish = '$c.paths.base/publish'
	c.paths.code = '$os.home_dir()/codewww'
	if ! os.exists(c.paths.code){
		os.mkdir(c.paths.code) or {panic(err)}
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

	return c
}

pub fn get() ?ConfigRoot {
	mut conf := get2()
	mut gt := gittools.new(conf.paths.code) or { return error('ERROR: cannot load gittools:$err') }
	for mut site in conf.sites {
		// println(' >> $site.name')
		if site.path_code == '' {
			// println(' >> $site.reponame() ')
			mut repo := gt.repo_get(name: site.reponame()) or {
				// return error('ERROR: cannot find repo: $site.name\n$err')
				// do NOTHING, just ignore the site to work with
				// print(err)
				println(' - WARNING: did not find site: $site.name, $err')				
				continue
			}
			site.path_code = repo.path_get()
		}
	}
	return conf
}
