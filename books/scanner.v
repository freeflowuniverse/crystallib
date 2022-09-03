module books

import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.pathlib
import os

// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut site Site) file_remember(mut path pathlib.Path) ?&File {
	mut file := file_new(mut path)?

	// println(' - File remember $file.pathrel')

	mut namelower := path.name_fix()

	// $if debug {eprintln(@FN + ": - $patho.path")}

	if patho.is_image() {
		if site.image_exists(namelower) {
			mut image_double := site.image_get(namelower, mut publisher)?
			mut pathdouble := image_double.path_object_get(mut publisher)?

			if publisher.healcheck() {
				println(' - try to heal, double file: $patho.path')

				println(namelower)
				println(image_double)

				mut prio_double := false

				if pathdouble.name_ends_with_underscore() {
					if patho.name_ends_with_underscore() {
						return site.error_report_file(mut &file, 'found 2 images with _ at end: $pathdouble.path')
					}
					prio_double = true
				} else if patho.extension() == 'jpg' && pathdouble.extension() == 'png' {
					// means are both jpg but the double one has underscore so prio
					prio_double = true
				}
				if prio_double {
					println(' - delete double: $patho.path')
					patho.delete()?
					// nothing to do in table ok there
					return site.image_get(namelower, mut publisher)
				} else {
					// means we have to put the path on this one				
					publisher.files[image_double.id].pathrel = pathrelative
					println(' - delete double: $pathdouble.path')
					pathdouble.delete()?
					return site.image_get(namelower, mut publisher)
				}
			} else {
				// no automatic check
				return site.error_report_file(mut &file, 'duplicate file $pathdouble.path')
			}
		} else {
			// means the its a new one, lets add it, first see if it needs to be downsized
			if imagemagick.installed {
				imagedownsized := imagemagick.image_downsize(patho.path)?
				// after downsize it could be the path has been changed, need to set it on the file
				file.pathrel = imagedownsized.path.path_relative(site.path)
			}
			mut file_out := file_add(mut file, mut publisher)
			site.images[namelower] = file_out.id
			return file_out
		}
	} else {
		// now we are working on non image
		if site.file_exists(namelower) {
			file_double := site.file_get(namelower, mut publisher)?
			return site.error_report_file(mut &file, 'duplicate file $file_double.pathrel')
		} else {
			mut file_out := file_add(mut file, mut publisher)
			site.files[namelower] = file_out.id
			return file_out
		}
	}
}

fn (mut site Site) error_report_file(mut file File, msg string) &File {
	pathrelative := file.pathrel
	errormsg := 'Error in remember file for site: $pathrelative\n $msg'
	site.error(pathrelative, errormsg, .duplicatefile)
	return file
}

// fn (mut site Site) sidebar_remember(path string, pageid int){

// 	mut path_sidebar_relative := path[site.path.len..]
// 	path_sidebar_relative = path_sidebar_relative.replace("//","/").trim(" /")
// 	site.sidebars[path_sidebar_relative] = pageid

// }

// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut site Site) file_remember_full_path(full_path string) ?&File {
	mut path_ := pathlib.get_file(full_path, false)?
	return site.file_remember(mut path_, mut publisher)
}

fn (mut site Site) page_remember(path string, name string, issidebar bool) ?&Page {
	mut namelower := publisher.name_fix_alias_page(name)?
	if namelower.trim(' ') == '' {
		site.error(path, 'empty page pagename', .emptypage)
		return none
	}
	if path.trim(' ') == '' {
		return error('path cannot be empty')
	}
	mut pathfull := os.join_path(path, name)
	mut pathfull_fixed := os.join_path(path, namelower) + '.md'
	if pathfull_fixed != pathfull {
		println(' - mv page remember, because name not normalized: $pathfull to $pathfull_fixed')
		os.mv(pathfull, pathfull_fixed)?
		pathfull = pathfull_fixed
	}
	pathrelative := pathfull[site.path.len..]

	if issidebar {
		mut path_sidebar := os.join_path(path, namelower)
		mut path_sidebar_relative := path_sidebar[site.path.len..]
		path_sidebar_relative = path_sidebar_relative.replace('//', '/').trim(' /')
		namelower = path_sidebar_relative.replace('/', '|')
		// println(" - found sidebar: $namelower")
		// path_sidebar_relative = texttools.name_fix(path_sidebar_relative)
		// println(" ----- $pathrelative $path_sidebar_relative"
	}

	if site.page_exists(namelower) {
		// panic('duplicate path: ' + path + '/' + name)
		pageduplicate := site.page_get(namelower, mut publisher)?
		site.error(pathrelative, 'duplicate page $pageduplicate.path', .duplicatepage)
		return none
	} else {
		mut sidebar_last_id := 999999
		if publisher.pages.len == 0 {
			publisher.pages = []Page{}
		}
		if !issidebar {
			if site.sidebars_last.len == 0 {
				site.error(path, 'site $site.name needs to have sidebar in root of site.',
					.sidebar)
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

		mut lastpage := &publisher.pages[publisher.pages.len - 1]

		if issidebar {
			// println(" --SIDEBAR- $new_page.path -- $site.path")
			// needs to happen manually because otherwise the sidebar itself doesn't have the id

			lastpage.sidebarid = new_page.id
			site.sidebars_last << lastpage

			// CAN REMOVE THIS !!!
			if publisher.pages.last().sidebarid == 999999 {
				println(new_page)
				println(publisher.pages.last())
				panic('just to check, should not be')
			}
			if lastpage.sidebarid == 999999 {
				panic('not be')
			}
		}

		return lastpage
	}
}

// path is the full path
fn (mut site Site) files_process_recursive(path_ string) ? {
	p := pathlib.get_dir(path_, false)
	p.namefix()?
	items := os.ls(path_)?
	// println(" - load: $path_")
	mut path_sidebar := '$path_/sidebar.md'
	// println(" - sidebar check: $path_/sidebar.md")
	if os.exists(path_sidebar) {
		// means we are not in root of path
		// _ := site.page_remember(path_, 'sidebar.md', true, mut publisher)?
		println(' - Found sidebar: $p.path')
	}
	// site.side_bar_fix(path_, mut publisher)

	for item in items {
		pathfull := os.join_path(p.path, item)
		if os.is_dir(pathfull) {
			if item.starts_with('.') {
				continue
			} else if item.starts_with('_') {
				continue
			} else if item.starts_with('gallery_') {
				// TODO: need to be implemented by macro
				continue
			} else {
				site.files_process_recursive(pathfull)?
				// site.side_bar_fix(path_, mut publisher)
			}
		} else {
			if item.starts_with('.') || item.to_lower() == 'defs.md' {
				continue
			} else if item.contains('.test') {
				os.rm(os.join_path(path_, item))?
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
				// filename_new := publisher.name_fix_alias_file(item2)?
				// if item2 != filename_new {
				// 	// means file name not ok
				// 	a := os.join_path(path_, item2)
				// 	b := os.join_path(path_, filename_new)
				// 	// println(' -- $a -> $b')
				// 	os.mv(a, b)?
				// 	item2 = filename_new
				// }

				if ext != '' {
					// only process files which do have extension
					ext2 := ext[1..]
					if ext2 == 'md' {
						_ := site.page_remember() or { continue }
					}

					if ext2 in ['jpg', 'png', 'svg', 'jpeg', 'gif', 'pdf', 'zip'] {
						// println(path+"/"+item2)
						mut fullpath := pathlib.get_file('$path_/$item2', false)?
						site.file_remember(mut fullpath, mut publisher)?
					}
				}
			}
		}
	}
	// here we also need to maybe go one lower in the stack, because we might return up
	// TODO:...
}
