module publisher_config

import os
import texttools
import json
import gittools
import actionparser

fn config_init() ConfigRoot {
	mut config := ConfigRoot{}
	return config
}

// load the initial config from filesystem
fn (mut config ConfigRoot) init_once() ? {
	envs := os.environ()

	if 'PUBSITE' in envs && envs['PUBSITE'].trim(' ') != '' {
		mut gt2 := gittools.get()?
		url := envs['PUBSITE']
		// println(' - found PUBSITE in environment variables, will use this one for config dir.')
		println(' - get git repo to fetch configuration for publ tools: $url')
		r := gt2.repo_get_from_url(url: url, pull: false)?
		// println(' - changedir for config: $r.path_content_get()')
		os.chdir(r.path_content_get())?
	}

	// Load Site & Group config files
	mut sites_config_files := []string{}
	mut groups_config_files := []string{}
	mut md_config_files := []string{}

	current_dir := '.'
	mut files := os.ls(current_dir) or {
		return error('Cannot load config files in current dir, $err')
	}
	for file in files {
		// println(" - $file")
		if file.starts_with('site_') && file.ends_with('.json') {
			sites_config_files << file
		}
		if file.starts_with('groups_') && file.ends_with('.json') {
			groups_config_files << file
		}

		if file.ends_with('.md') {
			md_config_files << file
		}
	}

	if sites_config_files.len == 0 && md_config_files.len == 0 {
		curdir := os.getwd()
		return error('cannot find site files in current dir: $curdir, site files start with site_ or there needs to be an .md file')
	}

	// will check if there are site_... files, if not is error

	// Load Publish config
	if os.exists('config.json') {
		println(' - Found config file for publish tools.')
		txt := os.read_file('config.json')?
		config.publish = json.decode(PublishConfig, txt)?
	} else {
		// println(' - Not Found config file for publish tools. Default values applied')
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

	// DEFAULT VALUES
	config.nodejs = NodejsConfig{
		version: NodejsCat.lts
		// means we don't install in platform
		nvm: true
	}

	// Load nodejs config
	if os.exists('nodejs.json') {
		println(' - Found config file for NodeJS.')
		txt := os.read_file('nodejs.json')?
		fsnodejs := json.decode(NodejsConfigFS, txt)?
		if fsnodejs.version == 'lts' {
			config.nodejs.version = NodejsCat.lts
		} else {
			config.nodejs.version = NodejsCat.latest
		}
		config.nodejs.nvm = fsnodejs.nvm
		// } else {
		// 	println(' - Not Found config file for NodeJS. Default values applied')
	}
	config.init_nodejs() // Init nodejs configurations

	config.web_hostnames = false

	// Load Static config
	staticfiles_config(mut &config)

	for site_file in sites_config_files {
		// println(' - found $site_file as a config file for sites.')
		txt := os.read_file(site_file)?
		// mut site_in := json.decode(SiteConfig, txt) ?
		mut site_in_raw := json.decode(SiteConfigRaw, txt) or { panic(err) }
		if site_in_raw.name == '' {
			site_in_raw.name = site_file.to_lower().replace('.json', '').replace('site_',
				'')
			if site_in_raw.name == 'wiki' {
				return error('wiki is not allowed as name for a wiki site')
			}
		}
		// default is wiki
		if site_in_raw.cat == '' {
			site_in_raw.cat = 'wiki'
		}
		// make sure we normalize the name
		site_in_raw.name = texttools.name_fix(site_in_raw.name)
		// site_in.configroot = &config
		// println(site_in_raw)
		mut site_in := site_new(site_in_raw)?
		config.sites << site_in
	}

	for md_file in md_config_files {
		config.markdown_configs << md_file

		res := actionparser.parse(md_file)?

		for action in res.actions {
			// find actions with name wiki, rest can be ignored for now

			if action.name == 'wiki' {
				mut sc := SiteConfigRaw{}

				// now walk over params
				for param in action.params {
					if param.name == 'name' {
						sc.name = texttools.name_fix(param.value)
					}
					if param.name == 'path' {
						sc.fs_path = param.value
					}
					if param.name == 'url' {
						sc.git_url = param.value
					}
				}
				sc.cat = 'wiki'
				mut site_in := site_new(sc)?
				config.sites << site_in
			}
		}
	}

	// Load Groups
	for group_file in groups_config_files {
		println(' - found $group_file as a config file for group.')
		txt := os.read_file(group_file)?
		config.groups << json.decode([]UserGroup, txt)?
	}

	println(' - CONFIG LOADED FOR $os.getwd()')
}

pub fn (mut site SiteConfig) load() ? {
	if site.state == SiteState.loaded {
		return
	}

	// println(" - process site: $site.name")

	if !site.path.exists() {
		return error('- Error Cannot find `$site.path.path` for \n$site\nin process site repo. Creating `$site.path.path`')
	}

	mut o := site.path.join('index.html')?
	o.delete()?
	mut o2 := site.path.join('wikiconfig.json')?
	o2.delete()?
}

// to create singleton
const gconf = config_init()

pub fn singleton() &ConfigRoot {
	return &publisher_config.gconf
}

pub fn get() ?&ConfigRoot {
	mut cr := singleton()
	if !cr.loaded {
		cr.init_once()?
		cr.loaded = true
	}
	return cr
}
