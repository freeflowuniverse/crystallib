module books

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.imagemagick
import freeflowuniverse.crystallib.texttools

// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut site Site) file_remember(mut p pathlib.Path) ? {
	// $if debug {eprintln(" - file remember : $p.path")}
	p.namefix()?
	namelower := p.name_fix_no_underscore_no_ext()
	if false && p.is_image() {
		if site.image_exists(namelower, false) {
			mut filedouble := site.image_get(namelower, false)?
			mut pathdouble := filedouble.path

			// get config item to see if we can heal
			// if site.sites.config.heal {
			// 	println(" - try to heal, double file: '$p.path' and '$pathdouble.path'")				
			// 	mut prio_double := false
			// 	if p.extension() == 'png'{
			// 		// if pathdouble.extension() == 'jpg'{
			// 		// 	println("prio jpg")
			// 		// 	prio_double = true
			// 		// }else if pathdouble.extension() == 'jpg'{

			// 	}else if pathdouble.name_ends_with_underscore() && p.name_ends_with_underscore() {
			// 		if p.path.len > pathdouble.path.len{
			// 			//this means double path is on shorter location than the one here
			// 			prio_double = true
			// 		}
			// 	} else if p.extension() == 'jpg' && pathdouble.extension() == 'jpg'{{
			// 		// means are both jpg but the double one has underscore so prio
			// 		prio_double = true
			// 	}
			// 	if prio_double {
			// 		// means we have to put the path on this one				
			// 		filedouble.path = pathdouble
			// 		filedouble.init()
			// 		println(' - delete original: $p.path')
			// 		// patho.delete()?
			// 	} else {
			// 		println(' - delete double: $pathdouble.path')
			// 		// pathdouble.delete()?
			// 		// TODO: need to do the actual deletes
			// 		site.file_new(mut p)?
			// 	}
			// } else {
			// 	// no automatic check
			// 	site.error(path: pathdouble, msg: 'duplicate file', cat: .image_double)
			// }
		} else {
			// means the its a new one, lets add it, first see if it needs to be downsized
			if imagemagick.installed() {
				imagedownsized := imagemagick.image_downsize(mut p, '')?
				// after downsize it could be the path has been changed, need to set it on the file
				if p.path != imagedownsized.path.path {
					p.path = imagedownsized.path.path
					p.check()
				}
			}
			site.file_new(mut p)?
		}
	} else {
		// now we are working on non image
		if site.file_exists(namelower, false) {
			mut filedouble := site.file_get(namelower, false)?
			mut pathdouble := filedouble.path
			site.error(path: pathdouble, msg: 'duplicate file', cat: .image_double)
		} else {
			site.file_new(mut p)?
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
	patho.namefix()?
	namelower := patho.name_fix_no_underscore_no_ext()
	if site.page_exists(namelower, false) {
		site.error(path: patho, msg: 'double page in site', cat: .page_double)
	}
	site.page_new(mut patho)?
}

// path is the full path
fn (mut site Site) scan_internal(mut p pathlib.Path) ? {
	// println(' - load site:$site.name - $p.path')
	// mut path_sidebar := '$p.path/sidebar.md'
	// println(" - sidebar check: $path_/sidebar.md")
	// if os.exists(path_sidebar) {
	// 	// means we are not in root of path
	// 	mut p2 := pathlib.get_file(path_sidebar, false)?
	// 	site.page_remember(mut p2, true)?
	// 	println(' - Found sidebar: $p.path')
	// }
	mut llist := p.list(recursive: false)?
	for mut p_in in llist {
		p_name := p_in.name()
		if p_name.starts_with('.') {
			continue
		} else if p_name.starts_with('_') {
			continue
		}

		if mut p_in.is_link() {
			// should support dir's and files
			link_real_path := p_in.realpath() // this is with the symlink resolved
			site_abs_path := site.path.absolute()
			if p.extension_lower() == 'md' {
				// means we are linking pages,this should not be done, need or change
				site.error(path: p_in, msg: 'duplicate page', cat: .page_double)
				return
			}
			if !link_real_path.starts_with(site_abs_path) {
				// means we are not in the site so we need to copy
				// $if debug{println(" - @FN IS LINK: \n    abs:'$link_abs_path' \n    real:'$link_real_path'\n    site:'$site_abs_path'")}
				p_in.unlink()? // will transform link to become the file or dir it points too
				assert !p_in.is_link()
			} else {
				p_in.relink()? // will check that the link is on the file with the shortest path
				println(p_in)
				panic('78gybh')
			}
		}
		if p_in.cat == .linkfile {
			// means we link to a file which is in the folder, so can be loaded later, nothing to do here
			return
		}

		if p_in.is_dir() {
			if p_name.starts_with('gallery_') {
				// TODO: need to be implemented by macro
				continue
			} else if p_name == 'books' {
				p_in.delete()?
				continue
			} else {
				site.scan_internal(mut p_in)?
				// site.side_bar_fix(path_, mut publisher)
			}
		} else {
			if p_name.to_lower() == 'defs.md' {
				continue
			} else if p_name.contains('.test') {
				p_in.delete()?
				continue
				// } else if p_name.starts_with('_'){
				//  && !(p_name.starts_with('_sidebar'))
				// 	&& !(p_name.starts_with('_glossary')) && !(p_name.starts_with('_navbar')) {
				// 	// println('SKIP: $item')
				// continue
			} else if p_in.path.starts_with('sidebar') {
				continue
			} else {
				ext := p_in.extension().to_lower()
				if ext != '' {
					// only process files which do have extension
					p_in.namefix()? // make sure name is proper on filesystem
					if ext == 'md' {
						site.page_remember(mut p_in, false)?
					} else {
						site.file_remember(mut p_in)?
					}
				}
			}
		}
	}
}
