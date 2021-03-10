module publishermod

import os
import json
import despiegk.crystallib.myconfig

struct PublisherErrors {
pub mut:
	site_errors []SiteError
	page_errors map[string][]PageError
}

struct PublisherDefs {
mut:
	defs []PublisherDef
}

struct PublisherDef {
	def  string
	page string
	site string
}

pub fn (mut publisher Publisher) errors_get(site Site) ?PublisherErrors {
	mut errors := PublisherErrors{}

	// collect all errors in a datastruct
	for err in site.errors {
		// errors.site_errors << err
		// TODO: clearly not ok, the duplicates files check is not there
		if err.cat != SiteErrorCategory.duplicatefile && err.cat != SiteErrorCategory.duplicatepage {
			errors.site_errors << err
		}
	}

	for name, page_id in site.pages {
		page := publisher.page_get_by_id(page_id) ?
		if page.errors.len > 0 {
			errors.page_errors[name] = page.errors
		}
	}

	return errors
}

// destination is the destination path for the flatten operation
pub fn (mut publisher Publisher) flatten() ? {
	mut dest_file := ''

	mut config := myconfig.get(true) ?

	publisher.check() // makes sure we checked all

	// process all definitions, will do over all sites
	mut pd := PublisherDefs{}
	for def, defobj in publisher.defs {
		page_def := publisher.page_get_by_id(defobj.pageid) ?
		site_def := page_def.site_get(mut publisher) ?
		pd.defs << PublisherDef{
			def: def
			page: page_def.name
			site: site_def.name
		}
	}

	for mut site in publisher.sites {
		site.files_process(mut publisher) ?

		// src_path[site.id] = site.path
		mut dest_dir := config.path_publish_wiki_get(site.name) ?
		println(' - flatten: $site.name to $dest_dir')

		errors2 := publisher.errors_get(site) ?

		if !os.exists(dest_dir) {
			os.mkdir_all(dest_dir) ?
		}
		// write the json errors file
		os.write_file('$dest_dir/errors.json', json.encode(errors2)) ?
		for c in config.sites {
			if c.cat == myconfig.SiteCat.web {
				continue
			}
			// ignore websites
			if c.shortname == site.name {
				os.write_file('$dest_dir/.domains.json', json.encode(map{
					'domains': c.domains
				})) ?

				os.write_file('$dest_dir/.repo', json.encode(map{
					'repo':  c.name
					'alias': c.shortname
				})) ?

				os.write_file('$dest_dir/.acls.json', json.encode(map{
					'users':  []string{}
					'groups': []string{}
				})) ?

				break
			}
		}

		// write the defs file
		os.write_file('$dest_dir/defs.json', json.encode(pd)) ?

		mut site_config := config.site_wiki_get(site.name) ?

		template_wiki_root_save(dest_dir, site.name, site_config.url)

		mut special := ['readme.md', 'README.md', '_sidebar.md', '_navbar.md', 'sidebar.md', 'navbar.md']

		// renameitems := [["_sidebar.md","sidebar.md"],["_navbar.md","navbar.md"]]
		// for ffrom,tto in renameitems{
		// 	if os.exists('$site.path/$ffrom'){
		// 		if os.exists('$site.path/$tto'){
		// 			os.rm('$site.path/$ffrom') ?
		// 		}else{
		// 			os.cp('$site.path/$ffrom','$site.path/$tto')?
		// 		}				
		// 		os.rm('$site.path/$ffrom')?
		// 	}
		// }

		for file in special {
			dest_file = file
			if os.exists('$site.path/$file') {
				if dest_file.starts_with('_') {
					dest_file = dest_file[1..] // remove the _
				}
				// println("copy: $site.path/$file $dest_dir/$dest_file")
				os.cp('$site.path/$file', '$dest_dir/$dest_file') ?
			}
		}

		for name, _ in site.pages {
			mut page := site.page_get(name, mut publisher) ?
			// println(' >> $name: $page.path')
			// write processed content
			content := page.content_defs_replaced(mut publisher) ?
			dest_file = os.join_path(dest_dir, os.file_name(page.path_get(mut publisher)))
			os.write_file(dest_file, content) ?
		}

		for name, _ in site.files {
			mut fileobj := site.file_get(name, mut publisher) ?
			dest_file = os.join_path(dest_dir, os.file_name(fileobj.path))
			os.cp(fileobj.path_get(mut publisher), dest_file) ?
		}
	}
}
