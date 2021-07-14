module publisher_core

import despiegk.crystallib.texttools
import os
import json
import despiegk.crystallib.publisher_config

fn (mut publisher Publisher) load() ? {
	// remove code_wiki subdirs
	path_links := '$os.home_dir()/codewiki/'
	path_links_list := os.ls(path_links) ?
	for path_to_remove in path_links_list {
		if path_to_remove.starts_with('info_') {
			// os.rmdir(path_to_remove)?
			// println("---REMOVE $path_to_remove")
			// os.exec("rm -f $path_to_remove")?
			//TODO: faster way to remove, using vlang construct
			os.execute_or_panic('rm -f $path_links/$path_to_remove')
		}
	}

	for site in publisher.config.sites {
		println(site)
		// panic("ssss")
	}
	// publisher.find_sites_recursive(path) ?
}

///////////////////////////////////////////////////////// INTERNAL BELOW ////////////////
/////////////////////////////////////////////////////////////////////////////////////////

// load a site into the publishing tools
// name of the site needs to be unique
fn (mut publisher Publisher) load_site(name string) ? {
	

	name2 := texttools.name_fix(name)
	mut myconfig_site := publisher.config.site_get(name2) ?

	// link the dir in codewiki, makes it easy to edit
	path_links := '$os.home_dir()/codewiki/'
	target := '$path_links/$name'
	if myconfig_site.path == "" || !os.exists(myconfig_site.path){
		return error("Could not find config path.\n$myconfig_site")
	}
	if !os.exists(target) {
		os.symlink(myconfig_site.path, target) ?
	}

	println(' - load publisher: $myconfig_site.name - $myconfig_site.path')
	if !publisher.site_exists(name) {
		id := publisher.sites.len
		mut site := Site{
			id: id
			path: myconfig_site.path
			name: myconfig_site.name
			config: &myconfig_site
		}
		// site.config = &myconfig_site
		publisher.sites << site
		publisher.site_names[myconfig_site.name] = id
	} else {
		return error("should not load on same name 2x: '$myconfig_site.name'")
	}
}

// // find all wiki's, this goes very fast, no reason to cache
// fn (mut publisher Publisher) find_sites_recursive(path string) ? {
// 	mut path1 := ''
// 	if path == '' {
// 		path1 = '$os.home_dir()/code/'
// 	} else {
// 		path1 = path
// 	}

// 	items := os.ls(path1) or { return error('cannot find $path1') }
// 	publisher.gitlevel++
// 	for item in items {
// 		pathnew := os.join_path(path1, item)
// 		if os.is_dir(pathnew) {
// 			// println(" - $pathnew '$item' ${publisher.gitlevel}")
// 			if os.is_link(pathnew) {
// 				continue
// 			}
// 			// is the template of vlangtools itself, should not go in there
// 			if pathnew.contains('vlang_tools/templates') {
// 				continue
// 			}
// 			if os.exists(os.join_path(pathnew, 'wikiconfig.json')) {
// 				content := os.read_file(os.join_path(pathnew, 'wikiconfig.json')) or {
// 					return error('Failed to load json ${os.join_path(pathnew, 'wikiconfig.json')}')
// 				}
// 				repoconfig := json.decode(SiteRepoConfig, content) or {
// 					// eprintln()
// 					return error('Failed to decode json ${os.join_path(pathnew, 'wikiconfig.json')}')
// 				}
// 				publisher.load_site(repoconfig, pathnew) or { panic(err) }
// 				continue
// 			}
// 			if item == '.git' {
// 				publisher.gitlevel = 0
// 				continue
// 			}
// 			if publisher.gitlevel > 1 {
// 				continue
// 			}
// 			if item.starts_with('.') {
// 				continue
// 			}
// 			if item.starts_with('_') {
// 				continue
// 			}
// 			publisher.find_sites_recursive(pathnew) or { panic(err) }
// 		}
// 	}
// 	publisher.gitlevel--
// }
