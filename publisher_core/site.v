module publisher_core
import despiegk.crystallib.texttools
import os

// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut site Site) file_remember(path string, name string, mut publisher &Publisher) &File {
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


// fn (mut site Site) sidebar_remember(path string, pageid int){

// 	mut path_sidebar_relative := path[site.path.len..]
// 	path_sidebar_relative = path_sidebar_relative.replace("//","/").trim(" /")
// 	site.sidebars[path_sidebar_relative] = pageid

// }


// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut site Site) file_remember_full_path(full_path string, mut publisher &Publisher) &File {
	return site.file_remember(os.dir(full_path), os.base(full_path), mut publisher)
}

fn (mut site Site) page_remember(path string, name string, mut publisher &Publisher) ?int {
	mut namelower := publisher.name_fix_alias_page(name) or { panic(err) }
	if namelower.trim(' ') == '' {
		site.errors << SiteError{
			path: path
			error: 'empty page pagename'
			cat: SiteErrorCategory.emptypage
		}
		// panic('empty page name:$path + $name')
	}
	if path.trim(" ") == ""{
		panic("path cannot be empty")
	}
	mut pathfull := os.join_path(path, name)
	mut pathfull_fixed := os.join_path(path, namelower) + '.md'
	if pathfull_fixed != pathfull {
		println(" - mv page remember, because name not normalized: $pathfull to $pathfull_fixed")
		os.mv(pathfull, pathfull_fixed) or { panic(err) }
		pathfull = pathfull_fixed
	}
	pathrelative := pathfull[site.path.len..]

	if namelower == "sidebar"{
		mut path_sidebar := os.join_path(path, namelower)
		mut path_sidebar_relative := path_sidebar[site.path.len..]
		path_sidebar_relative = path_sidebar_relative.replace("//","/").trim(" /")
		namelower = path_sidebar_relative.replace("/","|")
		// println(" - found sidebar: $namelower")
		// path_sidebar_relative = texttools.name_fix(path_sidebar_relative)
		// println(" ----- $pathrelative $path_sidebar_relative")
	}

	if site.page_exists(namelower) {
		// panic('duplicate path: ' + path + '/' + name)
		new_error := SiteError{
			path: pathrelative
			error: 'duplicate page $pathrelative'
			cat: SiteErrorCategory.duplicatepage
		}
		site.errors << new_error
		return 0
	} else {
		if publisher.pages.len == 0 {
			publisher.pages = []Page{}
		}
		new_page := Page{
			id: publisher.pages.len
			site_id: site.id
			name: namelower
			path: pathrelative
			sidebarid: site.sidebar_last
		}
		publisher.pages << new_page
		site.pages[namelower] = publisher.pages.len - 1		
		// println(" ------- $new_page.sidebarid")
		return publisher.pages.len - 1
	}
	
}

pub fn (mut site Site) reload(mut publisher &Publisher) ?{
	site.state = SiteState.init
	site.pages = map[string]int{}
	site.files = map[string]int{}
	site.errors = []SiteError{}
	site.files_process(mut publisher)?
	site.load(mut publisher)?
	site.sidebar_last = 0
}

pub fn (mut site Site) load(mut publisher &Publisher) ? {
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
		mut p := publisher.page_get_by_id(id)?
		p.load(mut publisher) ?
	}

	site.state = SiteState.loaded
}

pub fn (mut site Site) process(mut publisher &Publisher)? {
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
fn (mut site Site) files_process(mut publisher &Publisher) ? {
	if !os.exists(site.path) {
		return error("cannot find site on path:'$site.path'")
	}
	site.sidebar_last = 0
	return site.files_process_recursive(site.path, mut publisher)
}

fn (mut site Site) files_process_recursive(path string, mut publisher &Publisher) ? {
	items := os.ls(path) ?
	mut path_sidebar := "$path/sidebar.md"
	if os.exists(path_sidebar){
		//means we are not in root of path
		sidebar_last := site.page_remember(path, "sidebar.md", mut publisher) ?
		if path != site.path{
			site.sidebar_last = sidebar_last
			//needs to happen manually because otherwise the sidebar itself doesn't have the id
			mut page_sidebar := publisher.page_get_by_id(site.sidebar_last) or { panic(err) }
			page_sidebar.sidebarid = sidebar_last
		}
	}else{
		if site.sidebar_last>0 {
			page_sidebar_found := publisher.page_get_by_id(site.sidebar_last) or { panic(err) }
			path_sidebar_found := os.dir(page_sidebar_found.path_get(mut publisher))+"/"
			path2 := path + "/"
			if ! path2.starts_with(path_sidebar_found){
				//means is not subdir of previous sidebar
				site.sidebar_last = 0
			}
		}
	}
	// if path.contains("/farming"){
	// 	println("\n - $path ($site.sidebar_last)")
	// 	if site.sidebar_last>0 {
	// 		page_sidebar2 := publisher.page_get_by_id(site.sidebar_last) or { panic(err) }
	// 		path_sidebar2 := os.dir(page_sidebar2.path_get(mut publisher))
	// 		println(" - SIDEBAR: '$path_sidebar2'")
	// 	}
	// }
	// if site.sidebar_last>0{
	// 	page_sidebar2 := publisher.page_get_by_id(site.sidebar_last) or { panic(err) }
	// 	// println("--R-- $path : $site.sidebar_last : ${page_sidebar2.path}")
	// }
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
			} else if item.starts_with('sidebar') {
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
						b:= site.page_remember(path, item2, mut publisher) ?

						// if path.contains("/farming"){
						// 	page4 := publisher.page_get_by_id(b) or { panic(err) }
						// 	println(" - $page4.path $page4.sidebarid")
						// }

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
