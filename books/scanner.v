module books

import freeflowuniverse.crystallib.pathlib
import imagemagick
import os

// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut site Site) file_remember(mut patho pathlib.Path) ? {
	// println(' - File remember $file.pathrel')
	patho.namefix()?
	// $if debug {eprintln(@FN + ": - $patho.path")}
	if patho.is_image() {
		if site.image_exists(patho.name()) {
			mut filedouble := site.image_get(patho.name())?
			mut pathdouble := filedouble.path

			// get config item to see if we can heal
			if site.sites.config.heal {
				println(' - try to heal, double file: $patho.path')
				println(pathdouble.path)
				mut prio_double := false
				if pathdouble.name_ends_with_underscore() {
					if patho.name_ends_with_underscore() {
						site.error(
							path: pathdouble
							msg: 'found 2 images with _ at end'
							cat: .doubleimage
						)
					}
					prio_double = true
				} else if patho.extension() == 'jpg' && pathdouble.extension() == 'png' {
					// means are both jpg but the double one has underscore so prio
					prio_double = true
				}
				if prio_double {
					// means we have to put the path on this one				
					filedouble.path = pathdouble
					filedouble.init()
					println(' - delete original: $patho.path')
					// patho.delete()?
				} else {
					println(' - delete double: $pathdouble.path')
					// pathdouble.delete()?
					// TODO: need to do the actual deletes
					site.file_new(mut patho)?
				}
			} else {
				// no automatic check
				site.error(path: pathdouble, msg: 'duplicate file', cat: .doubleimage)
			}
		} else {
			// means the its a new one, lets add it, first see if it needs to be downsized
			if imagemagick.installed() {
				imagedownsized := imagemagick.image_downsize(mut patho,"")?
				// after downsize it could be the path has been changed, need to set it on the file
				if patho.path != imagedownsized.path.path{
					patho.path = imagedownsized.path.path
					patho.check()
				}
			}
			site.file_new(mut patho)?
		}
	} else {
		// now we are working on non image
		if site.file_exists(patho.name()) {
			mut filedouble := site.file_get(patho.name())?
			mut pathdouble := filedouble.path
			site.error(path: pathdouble, msg: 'duplicate file', cat: .doubleimage)
		} else {
			site.file_new(mut patho)?
		}
	}
}

// fn (mut site Site) sidebar_remember(path string, pageid int){

// 	mut path_sidebar_relative := path[site.path.len..]
// 	path_sidebar_relative = path_sidebar_relative.replace("//","/").trim(" /")
// 	site.sidebars[path_sidebar_relative] = pageid

// }

// remember the file, so we know if we have duplicates
// also fixes the name
// fn (mut site Site) file_remember_full_path(full_path string) ?&File {
// 	mut path_ := pathlib.get_file(full_path, false)?
// 	return site.file_remember(mut path_, mut publisher)
// }

fn (mut site Site) page_remember(mut patho pathlib.Path, issidebar bool) ? {
	// if issidebar {
	// 	mut path_sidebar := os.join_path(path, namelower)
	// 	mut path_sidebar_relative := path_sidebar[site.path.len..]
	// 	path_sidebar_relative = path_sidebar_relative.replace('//', '/').trim(' /')
	// 	namelower = path_sidebar_relative.replace('/', '|')
	// 	// println(" - found sidebar: $namelower")
	// 	// path_sidebar_relative = texttools.name_fix(path_sidebar_relative)
	// 	// println(" ----- $pathrelative $path_sidebar_relative"
	// }

	if site.page_exists(patho.name()) {
		panic('duplicate path: ' + patho.path)
	}
	site.page_new(mut patho)?
}

// path is the full path
fn (mut site Site) scan_internal(mut p pathlib.Path) ? {
	p.namefix()?
	println(' - load: $p.path')
	mut path_sidebar := '$p.path/sidebar.md'
	// println(" - sidebar check: $path_/sidebar.md")
	if os.exists(path_sidebar) {
		// means we are not in root of path
		mut p2 := pathlib.get_file(path_sidebar, false)?
		site.page_remember(mut p2, true)?
		println(' - Found sidebar: $p.path')
	}
	// site.side_bar_fix(path_, mut publisher)
	mut llist := p.list(recursive: false)?
	for mut p_in in llist {
		p_name := p_in.name_no_ext()
		if p_in.is_dir() {
			if p_name.starts_with('.') {
				continue
			} else if p_name.starts_with('_') {
				continue
			} else if p_name.starts_with('gallery_') {
				// TODO: need to be implemented by macro
				continue
			} else {
				site.scan_internal(mut p_in)?
				// site.side_bar_fix(path_, mut publisher)
			}
		} else {
			if p_name.starts_with('.') || p_name.to_lower() == 'defs.md' {
				continue
			} else if p_name.contains('.test') {
				p_in.delete()?
			} else if p_name.starts_with('_') && !(p_name.starts_with('_sidebar'))
				&& !(p_name.starts_with('_glossary')) && !(p_name.starts_with('_navbar')) {
				// println('SKIP: $item')
				continue
			} else if p_in.path.starts_with('sidebar') {
				continue
			} else {
				ext := p_in.extension().to_lower()
				if ext != '' {
					// only process files which do have extension
					// ext2 := ext[1..]
					// println("----- $p_in ($ext)")
					if ext == 'md' {
						site.page_remember(mut p_in, false)?
					} else {
						// println(path+"/"+item2)
						site.file_remember(mut p_in)?
					}
				}
			}
		}
	}
	site.fix()?
}
