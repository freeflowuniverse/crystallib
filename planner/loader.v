module planner

import os
import json
import freeflowuniverse.crystallib.texttools

// use path="" if you want to go from os.home_dir()/code/	
pub fn (mut planner Planner) load(path string) ? {
	planner.gitlevel = -3 // we do this gitlevel to make sure we don't go too deep in the directory level
	planner.find_sites_recursive(path)?
}

///////////////////////////////////////////////////////// INTERNAL BELOW ////////////////
/////////////////////////////////////////////////////////////////////////////////////////

// load a site into the publishing tools
// name of the site needs to be unique
fn (mut planner Planner) load_site(repoconfig PlannerSiteConfig, path string) ? {
	println(repoconfig)
	repo_name_fixed := texttools.name_fix(repoconfig.name)
	mut site := PlannerSite{
		name: repo_name_fixed
		planner: &planner
	}
	site.path = path
	site.files_process()?

	// mut myconfig_site := cfg.site_get(repoconfig_site) or {
	// 	if '$err'.contains('Cannot find wiki site') {
	// 		// means we should not load because file is not in the site configs
	// 		return
	// 	}
	// 	return error('$cfg\n -- ERROR: sitename in config file ($repoconfig_site) on repo in git, does not correspond with configname publishtools config.')
	// }
	// path2 := path.replace('~', os.home_dir())
	// println(' - load planner: $repoconfig_site -> $myconfig_site.name - $path2')
	// if !planner.site_exists(myconfig_site.name) {
	// 	id := planner.sites.len
	// 	mut site := Site{
	// 		id: id
	// 		path: path2
	// 		name: myconfig_site.name
	// 	}
	// 	site.config = repoconfig
	// 	planner.sites << site
	// 	planner.site_names[myconfig_site.name] = id
	// } else {
	// 	return error("should not load on same name 2x: '$myconfig_site.name'")
	// }
}

// find all wiki's, this goes very fast, no reason to cache
fn (mut planner Planner) find_sites_recursive(path string) ? {
	mut path1 := ''
	if path == '' {
		path1 = '$os.home_dir()/code/'
	} else {
		path1 = path
	}

	items := os.ls(path1) or { return error('cannot find $path1') }
	planner.gitlevel++
	for item in items {
		pathnew := os.join_path(path1, item)
		if os.is_dir(pathnew) {
			// println(" - $pathnew '$item' $planner.gitlevel")
			if os.is_link(pathnew) {
				continue
			}
			// is the template of vlangtools itself, should not go in there
			if pathnew.contains('vlang_tools/templates') {
				continue
			}
			if os.exists(os.join_path(pathnew, 'plannerconfig.json')) {
				content := os.read_file(os.join_path(pathnew, 'plannerconfig.json')) or {
					return error('Failed to load json ${os.join_path(pathnew, 'plannerconfig.json')}')
				}
				repoconfig := json.decode(PlannerSiteConfig, content) or {
					// eprintln()
					return error('Failed to decode json ${os.join_path(pathnew, 'plannerconfig.json')}')
				}
				planner.load_site(repoconfig, pathnew)?
				continue
			}
			// if item == '.git' {
			// 	planner.gitlevel = 0
			// 	continue
			// }
			if planner.gitlevel > 1 {
				continue
			}
			if item.starts_with('.') {
				continue
			}
			if item.starts_with('_') {
				continue
			}
			planner.find_sites_recursive(pathnew) or { panic(err) }
		}
	}
	planner.gitlevel--
}

// process files in the site (find all files)
// they will not be processed yet
fn (mut site PlannerSite) files_process() ? {
	if !os.exists(site.path) {
		return error("cannot find site on path:'$site.path'")
	}
	println(' - site files process: $site.path')
	return site.files_process_recursive(site.path)
}

fn (mut site PlannerSite) files_process_recursive(path string) ? {
	items := os.ls(path)?
	for item in items {
		println(' - $item')
		if os.is_dir(os.join_path(path, item)) {
			if item.starts_with('.') {
				continue
			} else if item.starts_with('_') {
				continue
			} else {
				site.files_process_recursive(os.join_path(path, item))?
			}
		} else {
			if item.starts_with('.') || item.to_lower() == 'defs.md' {
				continue
			} else if item.contains('.test') {
				os.rm(os.join_path(path, item))?
			} else if item.starts_with('_') {
				continue
			} else {
				// for names we do everything case insensitive
				mut itemlower := item.to_lower()
				mut ext := os.file_ext(itemlower)

				mut item2 := item

				// filename_new := textools.name_fix(item2) ?
				// if item2 != filename_new {
				// 	// means file name not ok
				// 	a := os.join_path(path, item2)
				// 	b := os.join_path(path, filename_new)
				// 	// println(' -- $a -> $b')
				// 	os.mv(a, b) ?
				// 	item2 = filename_new
				// }

				if ext != '' {
					// only process files which do have extension
					ext2 := ext[1..]
					if ext2 == 'md' {
						site.page_remember(path, item2)?
					}

					// if ext2 in ['jpg', 'png', 'svg', 'jpeg', 'gif', 'pdf', 'zip'] {
					// 	// println(path+"/"+item2)
					// 	site.file_remember(path, item2, )
					// }
				}
			}
		}
	}
}

fn (mut site PlannerSite) page_remember(path string, name string) ? {
	println(' - page remember:$path/$name')
	name2 := texttools.name_fix_keepext(name)
	if name2.starts_with('story') {
		o := obj_new<Story>('$path/$name')?
		println(o)
	}
}
