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
		publisher.load_site(site.name) or {panic(err)}
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
	
	mysite_name := texttools.name_fix(name)
	mut mysite_config := publisher.config.site_get(mysite_name) ?
	mut mysite_path := ""
	// Get Path from fs or repo
	if mysite_config.fs_path != "" {
		mysite_path = os.join_path(publisher.config.publish.paths.code, mysite_config.fs_path)
	}else{
		mysite_path = os.join_path(publisher.config.publish.paths.code, mysite_name)
	}
	
	// link the dir in codewiki, makes it easy to edit
	path_links := '$os.home_dir()/codewiki/'
	target := '$path_links/$name'
	if (mysite_config.path == "" && mysite_config.fs_path == "") || !os.exists(mysite_path){
		println(error(" >>> ERROR FROM LOAD_SITE<<<"))
		println(error(" >>> FROM LOAD_SITE >> site: $mysite_name >> site path: $mysite_path"))
		return error("Could not find config path.\n$mysite_config")
	}
	if !os.exists(target) {
		os.symlink(mysite_path, target) ?
	}

	println(' - load publisher: $mysite_config.name - $mysite_path')
	if !publisher.site_exists(name) {
		id := publisher.sites.len
		mut site := Site{
			id: id
			path: mysite_path
			name: mysite_config.name
			config: &mysite_config
		}
		// site.config = &mysite_config
		publisher.sites << site
		publisher.site_names[mysite_config.name] = id
	} else {
		return error("should not load on same name 2x: '$mysite_config.name'")
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
