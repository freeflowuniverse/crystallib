module publisher_core

import os
import json
import publisher_config
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

	mut config := publisher_config.get()?

	config.update_staticfiles(false) ?

	publisher.check()? // makes sure we checked all

	// process all definitions, will do over all sites
	mut pd := PublisherDefs{}
	for defobj in publisher.defs {
		page_def := publisher.page_get_by_id(defobj.pageid) ?
		site_def := page_def.site_get(mut publisher) ?
		name :=  defobj.name_fixed()?
		pd.defs << PublisherDef{
			def: name
			page: page_def.name
			site: site_def.name
		}
	}

	for mut site in publisher.sites {
		sc:=site.config
		// Ignore Websites
		if sc.cat != publisher_config.SiteCat.wiki{
			println(' - Skip: $sc.name, It is not a wiki!')
			continue
		}
		println(' - publish:$sc.git_url()')

		// site.files_process(mut publisher) ? // NO NEED TO PROCESS SITE AGAIN ALREADY DONE IN CHECK LINE 55 FOR ALL WEBSITES
		

		// src_path[site.id] = site.path
		mut dest_dir := config.path_publish_wiki_get(site.name) ?
		println(' - flatten: $site.name to $dest_dir')
		
		// Remove destination directory to make sure no old content
		if os.exists(dest_dir) {
			os.rmdir_all(dest_dir) ?
		}
		// Create destination directory
		os.mkdir_all(dest_dir) ?

		mut dest_dir_publ := config.publish.paths.publish


		// write the json errors file
		errors_t := publisher.errors_get(site)?
		the_errors2 := json.encode_pretty(errors_t)
		os.write_file('$dest_dir/errors.json', the_errors2) ?
		// write the defs file
		the_defs := json.encode_pretty(pd)
		os.write_file('$dest_dir/defs.json', the_defs) ?

		mut site_config := config.site_wiki_get(site.name) ?

		site_config.publish_path = dest_dir

		the_config := json.encode_pretty(site_config.raw)
		os.write_file('$dest_dir/config_site.json', the_config) ?	
		os.write_file('$dest_dir_publ/config_wiki_'+site_config.name+'.json', the_config) ?		

		the_config_group := json.encode_pretty(config.groups)
		os.write_file('$dest_dir/config_groups.json', the_config_group) ?

		//the main index file for docsify
		giturl := site_config.git_url()
		template_wiki_root_save(dest_dir, site.name, giturl, site_config.trackingid,
			site_config.opengraph)?

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
			mut file_name_of_site_page_path := ""
			// Handle Multi Sidebars
			if name.contains("|"){
				file_name_of_site_page_path = name.replace("|", "_") + ".md"
			}else{
				file_name_of_site_page_path = os.file_name(site_page_path)
			}
			dest_file = os.join_path(dest_dir, file_name_of_site_page_path)
			os.write_file(dest_file, page.content) ?
		}

		mut file_counter := 0
		for name, _ in site.files {
			mut fileobj := site.file_get(name, mut publisher) ?
			dest_file = os.join_path(dest_dir, os.file_name(fileobj.pathrel))
			file_counter++
			trace_progress('    ${file_counter:4}, creating file $dest_file ...')
			source_file := fileobj.path_get(mut publisher)?
			os.cp(source_file, dest_file) ?
		}
	}

}

[if trace_progress?]
fn trace_progress(msg string) {
	eprintln(msg)
}
