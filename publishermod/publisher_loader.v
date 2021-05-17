module publishermod

import os
import json
import despiegk.crystallib.myconfig

// use path="" if you want to go from os.home_dir()/code/	
fn (mut publisher Publisher) find_sites(path string) ? {
	publisher.gitlevel = -2 // we do this gitlevel to make sure we don't go too deep in the directory level
	publisher.find_sites_recursive(path) ?
}

///////////////////////////////////////////////////////// INTERNAL BELOW ////////////////
/////////////////////////////////////////////////////////////////////////////////////////

// load a site into the publishing tools
// name of the site needs to be unique
fn (mut publisher Publisher) load_site(repoconfig SiteRepoConfig, path string) ? {
	mut cfg := myconfig.get() ?
	repoconfig_site := name_fix(repoconfig.name)
	mut myconfig_site := cfg.site_get(repoconfig_site) or {
		if '$err'.contains('Cannot find wiki site') {
			// means we should not load because file is not in the site configs
			return
		}
		return error('$cfg\n -- ERROR: sitename in config file ($repoconfig_site) on repo in git, does not correspond with configname publishtools config.')
	}
	path2 := path.replace('~', os.home_dir())
	println(' - load publisher: $repoconfig_site -> $myconfig_site.shortname - $path2')
	if !publisher.site_exists(myconfig_site.name) {
		id := publisher.sites.len
		mut site := Site{
			id: id
			path: path2
			name: myconfig_site.shortname
		}
		site.config = repoconfig
		publisher.sites << site
		publisher.site_names[myconfig_site.shortname] = id
	} else {
		return error("should not load on same name 2x: '$myconfig_site.name'")
	}
}

// find all wiki's, this goes very fast, no reason to cache
fn (mut publisher Publisher) find_sites_recursive(path string) ? {
	mut path1 := ''
	if path == '' {
		path1 = '$os.home_dir()/code/'
	} else {
		path1 = path
	}

	items := os.ls(path1) or { return error('cannot find $path1') }
	publisher.gitlevel++
	for item in items {
		pathnew := os.join_path(path1, item)
		if os.is_dir(pathnew) {
			// println(" - $pathnew '$item' ${publisher.gitlevel}")
			if os.is_link(pathnew) {
				continue
			}
			// is the template of vlangtools itself, should not go in there
			if pathnew.contains('vlang_tools/templates') {
				continue
			}
			if os.exists(os.join_path(pathnew, 'wikiconfig.json')) {
				content := os.read_file(os.join_path(pathnew, 'wikiconfig.json')) or {
					return error('Failed to load json ${os.join_path(pathnew, 'wikiconfig.json')}')
				}
				repoconfig := json.decode(SiteRepoConfig, content) or {
					// eprintln()
					return error('Failed to decode json ${os.join_path(pathnew, 'wikiconfig.json')}')
				}
				publisher.load_site(repoconfig, pathnew) or { panic(err) }
				continue
			}
			if item == '.git' {
				publisher.gitlevel = 0
				continue
			}
			if publisher.gitlevel > 1 {
				continue
			}
			if item.starts_with('.') {
				continue
			}
			if item.starts_with('_') {
				continue
			}
			publisher.find_sites_recursive(pathnew) or { panic(err) }
		}
	}
	publisher.gitlevel--
}
