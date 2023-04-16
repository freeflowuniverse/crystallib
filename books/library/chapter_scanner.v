module library

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.imagemagick

// path is the full path
fn (mut chapter Chapter) scan_internal(mut p pathlib.Path) ! {
	$if debug {
		println('--- scan internal ${p.path}')
	}
	mut llist := p.list(recursive: false)!
	for mut p_in in llist {
		// println("--- SCAN SUB:\n$p_in")
		if p_in.exists() == false {
			chapter.error(path: p_in, msg: 'probably a broken link', cat: .unknown)
			continue // means broken link
		}
		p_name := p_in.name()
		if p_name.starts_with('.') {
			continue
		} else if p_name.starts_with('_') {
			continue
		}

		if mut p_in.is_link() && p_in.is_file() {
			link_real_path := p_in.realpath() // this is with the symlink resolved
			chapter_abs_path := chapter.path.absolute()
			if p_in.extension_lower() == 'md' {
				// means we are linking pages,this should not be done, need or change
				chapter.error(path: p_in, msg: 'a markdown file should not be linked', cat: .unknown)
				continue
			}
			if !link_real_path.starts_with(chapter_abs_path) {
				// means we are not in the chapter so we need to copy
				// $if debug{println(" - @FN IS LINK: \n    abs:'$link_abs_path' \n    real:'$link_real_path'\n    chapter:'$chapter_abs_path'")}
				p_in.unlink()! // will transform link to become the file or dir it points too
				assert !p_in.is_link()
			} else {
				p_in.relink()! // will check that the link is on the file with the shortest path
				// println(p_in)
			}
		}
		if p_in.cat == .linkfile {
			// means we link to a file which is in the folder, so can be loaded later, nothing to do here
			continue
		}

		if p_in.is_dir() {
			if p_name.starts_with('gallery_') {
				// TODO: need to be implemented by macro
				continue
				// } else if p_name == 'chapters' {
				// 	p_in.delete()!
				// 	continue
			} else {
				chapter.scan_internal(mut p_in)!
				// chapter.side_bar_fix(path_, mut publisher)
			}
		} else {
			if p_name.to_lower() == 'defs.md' {
				continue
			} else if p_name.contains('.test') {
				p_in.delete()!
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
					if ext == 'md' {
						chapter.page_new(mut p_in)!
					} else {
						chapter.file_image_remember(mut p_in)!
					}
				}
			}
		}
	}
}

// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut chapter Chapter) file_image_remember(mut p pathlib.Path) ! {
	$if debug {
		eprintln(' - file or image remember : ${p.path}')
	}
	mut ptr := pointer.pointerpath_new(path: p.path, path_normalize: true, needs_to_exist: true)!
	p = ptr.path
	if ptr.is_image() {
		if chapter.heal && imagemagick.installed() {
			mut image := imagemagick.image_new(mut p) or {
				panic('Cannot get new image:\n${p}\n${err}')
			}
			image.downsize(backup: false)!
			// after downsize it could be the path has been changed, need to set it on the file
			if p.path != image.path.path {
				p.path = image.path.path
				p.check()
			}
		}
		if chapter.image_exists(ptr.pointer.name) {
			mut filedouble := chapter.image_get(ptr.pointer.name) or {
				panic('if image exists, I should be able to get it. \n${err}')
			}
			mut pathdouble := filedouble.path.path
			mut pathsource := p.path
			if pathsource.len < pathdouble.len + 1 {
				// nothing to be done, because the already existing file is shortest or equal
				return
			}
			// file double is the one who already existed, need to change the path and can delete original
			filedouble.path = filedouble.path
			filedouble.init()
			if chapter.heal {
				println(' - delete double image: ${p.path}')
				p.delete()!
			}
			return
		} else {
			// means the its a new one, lets add it, first see if it needs to be downsized
			chapter.image_new(mut p)!
		}
	} else if ptr.is_file_video_html() {
		// now we are working on non image
		if chapter.file_exists(ptr.pointer.name) {
			mut filedouble := chapter.file_get(ptr.pointer.name)!
			mut pathdouble := filedouble.path
			chapter.error(path: pathdouble, msg: 'duplicate file', cat: .image_double)
		} else {
			chapter.file_new(mut ptr.path)!
		}
	} else {
		panic('unknown obj type, bug')
	}
}

// fn (mut chapter Chapter) sidebar_remember(path string, pageid int){

// 	mut path_sidebar_relative := path[chapter.path.len..]
// 	path_sidebar_relative = path_sidebar_relative.replace("//","/").trim(" /")
// 	chapter.sidebars[path_sidebar_relative] = pageid

// }
