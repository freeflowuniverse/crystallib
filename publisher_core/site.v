module publisher_core

import os

// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut site Site) file_remember(path string, name string, mut publisher Publisher) &File {
	mut namelower := publisher.name_fix_alias_file(name) or { panic(err) }
	mut pathfull_fixed := os.join_path(path, namelower)
	mut pathfull := os.join_path(path, name)
	if pathfull_fixed != pathfull {
		os.mv(pathfull, pathfull_fixed) or { panic(err) }
		pathfull = pathfull_fixed
	}
	// now remove the root path
	pathrelative := pathfull[site.path.len..]
	// println(' - File $namelower <- $pathfull')
	if site.file_exists(namelower) {
		// error there should be no duplicates
		site.errors << SiteError{
			path: pathrelative
			error: 'duplicate file $pathrelative'
			cat: SiteErrorCategory.duplicatefile
		}
	} else {
		if publisher.files.len == 0 {
			publisher.files = []File{}
		}

		file := File{
			id: publisher.files.len
			site_id: site.id
			name: namelower
			path: pathrelative
		}
		// println("remember site: $file.name")
		publisher.files << file
		site.files[namelower] = publisher.files.len - 1
	}
	file0 := site.file_get(namelower, mut publisher) or { panic(err) }
	if file0.site_id > 1000 {
		panic('cannot be')
	}
	return file0
}

// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut site Site) file_remember_full_path(full_path string, mut publisher Publisher) &File {
	return site.file_remember(os.dir(full_path), os.base(full_path), mut publisher)
}

fn (mut site Site) page_remember(path string, name string, mut publisher Publisher) ? {
	mut namelower := publisher.name_fix_alias_page(name) or { panic(err) }
	if namelower.trim(' ') == '' {
		site.errors << SiteError{
			path: path
			error: 'empty page pagename'
			cat: SiteErrorCategory.emptypage
		}
		// panic('empty page name:$path + $name')
	}
	mut pathfull := os.join_path(path, name)
	mut pathfull_fixed := os.join_path(path, namelower) + '.md'
	if pathfull_fixed != pathfull {
		os.mv(pathfull, pathfull_fixed) or { panic(err) }
		pathfull = pathfull_fixed
	}
	pathrelative := pathfull[site.path.len..]
	if site.page_exists(namelower) {
		// panic('duplicate path: ' + path + '/' + name)
		site.errors << SiteError{
			path: pathrelative
			error: 'duplicate page $pathrelative'
			cat: SiteErrorCategory.duplicatepage
		}
	} else {
		if publisher.pages.len == 0 {
			publisher.pages = []Page{}
		}

		publisher.pages << Page{
			id: publisher.pages.len
			site_id: site.id
			name: namelower
			path: pathrelative
		}
		site.pages[namelower] = publisher.pages.len - 1
	}
}

pub fn (mut site Site) reload(mut publisher Publisher) ?{
	site.state = SiteState.init
	site.pages = map[string]int{}
	site.files = map[string]int{}
	site.errors = []SiteError{}
	site.files_process(mut publisher)?
	site.load(mut publisher)?
}

pub fn (mut site Site) load(mut publisher Publisher) ? {
	if site.state == SiteState.ok {
		return
	}

	if site.pages.len == 0 {
		site.files_process(mut publisher) ?
	}

	// publisher.replacer.site.add(site.config.sitereplace) ?
	// publisher.replacer.word.add(site.config.wordreplace) ?
	// publisher.replacer.file.add(site.config.filereplace) ?

	imgnotusedpath := site.path + '/img_notused'
	if !os.exists(imgnotusedpath) {
		os.mkdir(imgnotusedpath) ?
	}
	imgtosortpath := site.path + '/img_tosort'
	if !os.exists(imgtosortpath) {
		os.mkdir(imgtosortpath) ?
	}

	println(' - load pages for site: $site.name')
	for _, id in site.pages {
		mut p := publisher.page_get_by_id(id) ?
		p.load(mut publisher) ?
	}

	site.state = SiteState.loaded
}

pub fn (mut site Site) process(mut publisher Publisher)? {
	if site.state == SiteState.ok {
		return
	}

	if site.state != SiteState.loaded {
		panic('need to make sure site is always loaded before doing process')
	}

	println(' - process pages for site: $site.name')
	for _, id in site.pages {
		mut p := publisher.page_get_by_id(id)?
		p.process(mut publisher)?
	}
	println(' - process file for site: $site.name')
	for _, id in site.files {
		mut f := publisher.file_get_by_id(id) or {
			eprintln(err)
			continue
		}
		f.relocate(mut publisher)?
	}

	site.state = SiteState.ok
}

// process files in the site (find all files)
// they will not be processed yet
fn (mut site Site) files_process(mut publisher Publisher) ? {
	if !os.exists(site.path) {
		return error("cannot find site on path:'$site.path'")
	}
	return site.files_process_recursive(site.path, mut publisher)
}

fn (mut site Site) files_process_recursive(path string, mut publisher Publisher) ? {
	items := os.ls(path) ?
	for item in items {
		if os.is_dir(os.join_path(path, item)) {
			if item.starts_with('.') {
				continue
			} else if item.starts_with('_') {
				continue
			} else if item.starts_with('gallery_') {
				// TODO: need to be implemented by macro
				continue
			} else {
				site.files_process_recursive(os.join_path(path, item), mut publisher) ?
			}
		} else {
			if item.starts_with('.') || item.to_lower() == 'defs.md' {
				continue
			} else if item.contains('.test') {
				os.rm(os.join_path(path, item)) ?
			} else if item.starts_with('_') && !(item.starts_with('_sidebar'))
				&& !(item.starts_with('_glossary')) && !(item.starts_with('_navbar')) {
				// println('SKIP: $item')
				continue
			} else {
				// for names we do everything case insensitive
				mut itemlower := item.to_lower()
				mut ext := os.file_ext(itemlower)

				mut item2 := item

				filename_new := publisher.name_fix_alias_file(item2) ?
				if item2 != filename_new {
					// means file name not ok
					a := os.join_path(path, item2)
					b := os.join_path(path, filename_new)
					// println(' -- $a -> $b')
					os.mv(a, b) ?
					item2 = filename_new
				}

				if ext != '' {
					// only process files which do have extension
					ext2 := ext[1..]
					if ext2 == 'md' {
						site.page_remember(path, item2, mut publisher) ?
					}

					if ext2 in ['jpg', 'png', 'svg', 'jpeg', 'gif', 'pdf', 'zip'] {
						// println(path+"/"+item2)
						site.file_remember(path, item2, mut publisher)
					}
				}
			}
		}
	}
}
