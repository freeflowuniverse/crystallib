module publisher_core

import os
import json
import despiegk.crystallib.publisher_config

struct PublisherErrors {
pub mut:
	site_errors []SiteError
	page_errors map[string][]PageError
}

// this is used to write json to the flatten dir so the webserver can process defs
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

	mut config := publisher_config.get()
	config.update_staticfiles(false) ?

	publisher.check()? // makes sure we checked all

	// process all definitions, will do over all sites
	mut pd := PublisherDefs{}
	for defobj in publisher.defs {
		page_def := publisher.page_get_by_id(defobj.pageid) ?
		site_def := page_def.site_get(mut publisher) ?
		pd.defs << PublisherDef{
			def: defobj.name_fixed()
			page: page_def.name
			site: site_def.name
		}
	}

	for mut site in publisher.sites {
		site.files_process(mut publisher) ?

		// src_path[site.id] = site.path
		mut dest_dir := config.path_publish_wiki_get(site.name) ?
		println(' - flatten: $site.name to $dest_dir')
		if !os.exists(dest_dir) {
			os.mkdir_all(dest_dir) ?
		}
		// write the json errors file
		the_errors2 := json.encode(publisher.errors_get(site) ?)
		os.write_file('$dest_dir/errors.json', the_errors2) ?
		for c in config.sites {
			if c.cat == publisher_config.SiteCat.web {
				continue
			}
			// ignore websites
			if c.name == site.name {
				break
			}
		}
		// write the defs file
		the_defs := json.encode(pd)
		os.write_file('$dest_dir/defs.json', the_defs) ?

		mut site_config := config.site_wiki_get(site.name) ?

		template_wiki_root_save(dest_dir, site.name, site_config.git_url, site_config.trackingid,
			site_config.opengraph)

		mut special := ['readme.md', 'README.md', '_sidebar.md', '_navbar.md', 'sidebar.md',
			'navbar.md', 'favicon.ico']

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

		mut page_counter := 0
		for name, _ in site.pages {
			mut page := site.page_get(name, mut publisher) ?
			page_counter++
			trace_progress('    ${page_counter:4}, processing page $page.path ...')
			// println(' >> $name: $page.path')
			// write processed content
			page.replace_defs(mut publisher) ?
			site_page_path := page.path_get(mut publisher)
			file_name_of_site_page_path := os.file_name(site_page_path)
			dest_file = os.join_path(dest_dir, file_name_of_site_page_path)
			os.write_file(dest_file, page.content) ?
		}

		mut file_counter := 0
		for name, _ in site.files {
			mut fileobj := site.file_get(name, mut publisher) ?
			dest_file = os.join_path(dest_dir, os.file_name(fileobj.path))
			file_counter++
			trace_progress('    ${file_counter:4}, creating file $dest_file ...')
			os.cp(fileobj.path_get(mut publisher), dest_file) ?
		}
	}
	// publisher_config.save('') ? // This method no longer available
}

[if trace_progress?]
fn trace_progress(msg string) {
	eprintln(msg)
}
