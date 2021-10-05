module publisher_core
import os
import path
import imagemagick
import texttools

// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut site Site) file_remember(mut patho path.Path, mut publisher &Publisher) ?&File {
	patho.normalize() or {panic("cannot normalize $patho")}
	pathrelative := patho.path_relative(site.path)

	mut file := file_new(mut patho, site, mut publisher)?
	
	// println(' - File remember $file.pathrel')

	mut namelower := file.name_fixed(mut publisher)

	if patho.is_image(){		

		if site.image_exists(namelower){
				
			mut image_double := site.image_get(namelower, mut publisher)?
			mut pathdouble := image_double.path_object_get(mut publisher)?

			if publisher.healcheck() {
				println(" - try to heal, double file: $patho.path")

				println(namelower)
				println(image_double)

				mut prio_double := false

				if pathdouble.name_ends_with_underscore(){
					if patho.name_ends_with_underscore(){
						return site.error_report_file(mut &file, 'found 2 images with _ at end: ${pathdouble.path}')
					}
					prio_double = true
				}else if patho.extension() == "jpg" && pathdouble.extension() == "png" {
					//means are both jpg but the double one has underscore so prio
					prio_double = true
				}			
				if prio_double {
					println(" - delete double: $patho.path")
					patho.delete()?
					//nothing to do in table ok there
					return site.image_get(namelower, mut publisher)
				}else{
					//means we have to put the path on this one				
					publisher.files[image_double.id].pathrel = pathrelative
					println(" - delete double: $pathdouble.path")
					pathdouble.delete()?		
					return site.image_get(namelower, mut publisher)
				}
			}else{
				//no automatic check
				return site.error_report_file(mut &file, 'duplicate file ${pathdouble.path}')
			}
		}else{
			//means the its a new one, lets add it, first see if it needs to be downsized
			if imagemagick.installed{
				imagedownsized := imagemagick.image_downsize(patho.path)?
				//after downsize it could be the path has been changed, need to set it on the file
				file.pathrel = imagedownsized.path.path_relative(site.path)
			}
			mut file_out := file_add(mut file,mut publisher)
			site.images[namelower] = file_out.id
			return file_out
		}
	}else{
		//now we are working on non image
		if site.file_exists(namelower)  {
			file_double := site.file_get(namelower, mut publisher)?
			return site.error_report_file(mut &file, 'duplicate file ${file_double.pathrel}')
		}else{
			mut file_out := file_add(mut file,mut publisher)
			site.files[namelower] = file_out.id
			return file_out
		}
	}

	
}


fn (mut site Site) error_report_file(mut file &File, msg string) &File {
	pathrelative := file.pathrel
	errormsg := 'Error in remember file for site: $pathrelative\n $msg'
	site.error(pathrelative,errormsg,.duplicatefile)
	return file
}

// fn (mut site Site) sidebar_remember(path string, pageid int){

// 	mut path_sidebar_relative := path[site.path.len..]
// 	path_sidebar_relative = path_sidebar_relative.replace("//","/").trim(" /")
// 	site.sidebars[path_sidebar_relative] = pageid

// }


// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut site Site) file_remember_full_path(full_path string, mut publisher &Publisher)? &File {
	mut path_ := path.get_file(full_path,false)
	return site.file_remember(mut path_, mut publisher)
}

fn (mut site Site) page_remember(path string, name string, issidebar bool, mut publisher &Publisher) ?&Page {
	mut namelower := publisher.name_fix_alias_page(name) or { panic(err) }
	if namelower.trim(' ') == '' {
		site.error(path,'empty page pagename',.emptypage)
		return none
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

	if issidebar{
		mut path_sidebar := os.join_path(path, namelower)
		mut path_sidebar_relative := path_sidebar[site.path.len..]
		path_sidebar_relative = path_sidebar_relative.replace("//","/").trim(" /")
		namelower = path_sidebar_relative.replace("/","|")
		// println(" - found sidebar: $namelower")
		// path_sidebar_relative = texttools.name_fix(path_sidebar_relative)
		// println(" ----- $pathrelative $path_sidebar_relative"

	}

	if site.page_exists(namelower) {
		// panic('duplicate path: ' + path + '/' + name)
		pageduplicate := site.page_get(namelower,mut publisher)?
		site.error(pathrelative,'duplicate page $pageduplicate.path',.duplicatepage)		
		return none
	} else {
		mut sidebar_last_id:= 999999
		if publisher.pages.len == 0 {
			publisher.pages = []Page{}
		}
		if !issidebar{
			if site.sidebars_last.len == 0{
				site.error(path,"site $site.name needs to have sidebar in root of site.",.sidebar)
				return none
			}
			sidebar_last_id = site.sidebars_last.last().id
		}

		new_page := Page{
			id: publisher.pages.len
			site_id: site.id
			name: namelower
			path: pathrelative
			sidebarid: sidebar_last_id
		}
		publisher.pages << new_page
		site.pages[namelower] = publisher.pages.len - 1		
		// println(" ------- $new_page.sidebarid")

		mut lastpage := &publisher.pages[publisher.pages.len-1]

		if issidebar{
			// println(" --SIDEBAR- $new_page.path -- $site.path")
			//needs to happen manually because otherwise the sidebar itself doesn't have the id
			
			lastpage.sidebarid = new_page.id			
			site.sidebars_last << lastpage
			
			//CAN REMOVE THIS !!!
			if publisher.pages.last().sidebarid == 999999{
				println(new_page)
				println(publisher.pages.last())
				panic("just to check, should not be")
			}
			if lastpage.sidebarid == 999999{
				panic("not be")
			}
		}

		return lastpage
	}
	
}

pub fn (mut site Site) reload(mut publisher &Publisher) ?{
	site.state = SiteState.init
	site.pages = map[string]int{}
	site.files = map[string]int{}
	site.errors = []SiteError{}
	site.files_process(mut publisher)?
	site.load(mut publisher)?
	site.sidebars_last = []&Page{}
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
	for _, id in site.images {
		mut f := publisher.file_get_by_id(id) or {
			eprintln(err)
			continue
		}
		f.relocate(mut publisher)?
		// if f.name(mut publisher).contains("home_threefold_new"){
		// 	println(f)
		// 	panic("ssssss3")
		// }		
	}

	site.state = SiteState.ok
}

// process files in the site (find all files)
// they will not be processed yet
fn (mut site Site) files_process(mut publisher &Publisher) ? {
	println(" - find files/pages for site: $site.path")
	if !os.exists(site.path) {
		return error("cannot find site on path:'$site.path'")
	}
	site.sidebars_last = []&Page{}
	return site.files_process_recursive(site.path, mut publisher)
}

fn (mut site Site) side_bar_fix(path_ string, mut publisher &Publisher){
	if site.sidebars_last.len>0 {
		path2:=path_+"/"
		for sidebarpage in site.sidebars_last.reverse(){				
			path_sidebar_found := os.dir(sidebarpage.path_get(mut publisher))+"/"
			if ! path2.starts_with(path_sidebar_found){
				//remove last element of list because no longer the right path
				site.sidebars_last.pop()
				// println (" -- removed sidebar: $removed.path")
			}
		}
		// println(" ---- sidebar now: ${site.sidebars_last.last().path}")
	}
}
//path is the full path
fn (mut site Site) files_process_recursive(path__ string, mut publisher &Publisher) ? {
	mut path_ := path__
	namefixed := texttools.name_fix(os.base(path_)).trim(" _")
	if os.base(path_) != namefixed{
		src := os.dir(path_)+"/"+os.base(path_)
		dst := os.dir(path_)+"/"+namefixed
		os.mv(src,dst+"_")? //this is to deal if we only have uppercase to lowercase
		os.mv(dst+"_",dst)?
		path_ = dst
		// println(src)
		// println(dst)
		// panic("Sdssd")
	}
	items := os.ls(path_) ?
	println(" - load: $path_")
	mut path_sidebar := "$path_/sidebar.md"
	println(" - sidebar check: $path_/sidebar.md")
	if os.exists(path_sidebar){
		//means we are not in root of path
		p:= site.page_remember(path_, "sidebar.md", true, mut publisher) ?
		println (" - Found sidebar: $p.path")
	}	
	site.side_bar_fix(path_,mut publisher)
	// if path.contains("/farming"){
	// 	println("\n - $path ($site.sidebar_last)")
	// 	if site.sidebar_last>0 {
	// 		page_sidebar2 := publisher.page_get_by_id(site.sidebar_last) or { panic(err) }
	// 		path_sidebar2 := os.dir(page_sidebar2.path_get(mut publisher))
	// 		println(" - SIDEBAR: '$path_sidebar2'")
	// 	}
	// }
	for item in items {
		if os.is_dir(os.join_path(path_, item)) {
			if item.starts_with('.') {
				continue
			} else if item.starts_with('_') {
				continue
			} else if item.starts_with('gallery_') {
				// TODO: need to be implemented by macro
				continue
			} else {
				site.files_process_recursive(os.join_path(path_, item), mut publisher) ?
				site.side_bar_fix(path_,mut publisher)
			}
		} else {
			if item.starts_with('.') || item.to_lower() == 'defs.md' {
				continue
			} else if item.contains('.test') {
				os.rm(os.join_path(path_, item)) ?
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
					a := os.join_path(path_, item2)
					b := os.join_path(path_, filename_new)
					// println(' -- $a -> $b')
					os.mv(a, b) ?
					item2 = filename_new
				}

				if ext != '' {
					// only process files which do have extension
					ext2 := ext[1..]
					if ext2 == 'md' {
						_:= site.page_remember(path_, item2, false, mut publisher) or {
							continue
						}

						// if path.contains("/farming"){
						// 	page4 := publisher.page_get_by_id(b) or { panic(err) }
						// 	println(" - $page4.path $page4.sidebarid")
						// }

					}

					if ext2 in ['jpg', 'png', 'svg', 'jpeg', 'gif', 'pdf', 'zip'] {
						// println(path+"/"+item2)
						mut fullpath := path.get_file("$path_/$item2",false)
						site.file_remember(mut fullpath, mut publisher)?
					}
				}
			}
		}
	}
	//here we also need to maybe go one lower in the stack, because we might return up
	//TODO:...
}
