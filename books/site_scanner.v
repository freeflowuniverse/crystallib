module books

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.imagemagick

// remember the file, so we know if we have duplicates
// also fixes the name
fn (mut site Site) file_image_remember(mut p pathlib.Path) ? {
	// $if debug {eprintln(" - file or image remember : $p.path")}
	p.path_normalize()?
	namesmallest := p.name_fix_no_underscore_no_ext()
	if p.is_image() {
		p.path_normalize()? // make sure its all lower case and name is proper
		if imagemagick.installed() {
			imagedownsized := imagemagick.image_downsize(mut p, '')?
			// after downsize it could be the path has been changed, need to set it on the file
			if p.path != imagedownsized.path.path {
				p.path = imagedownsized.path.path
				p.check()
			}
		}
		if site.image_exists(namesmallest) {
			mut filedouble := site.image_get(namesmallest)?
			mut pathdouble := filedouble.path.path
			mut pathsource := p.path
			if pathsource.len < pathdouble.len+1{
				//nothing to be done, because the already existing file is shortest or equal
				return
			}
			//file double is the one who already existed, need to change the path and can delete original
			filedouble.path = filedouble.path
			filedouble.init()
			println(' - delete double image: $p.path')
			p.delete()?
			return
		} else {
			// means the its a new one, lets add it, first see if it needs to be downsized
			site.image_new(mut p)?
		}
	} else {
		// now we are working on non image
		if site.file_exists(namesmallest) {
			mut filedouble := site.file_get(namesmallest)?
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
			// should support dirs only
			link_real_path := p_in.realpath() // this is with the symlink resolved
			site_abs_path := site.path.absolute()
			if p.extension_lower() == 'md' {
				// means we are linking pages,this should not be done, need or change
				site.error(path: p_in, msg: 'a markdown file should not be linked', cat: .unknown)
				continue
			}
			if !link_real_path.starts_with(site_abs_path) {
				// means we are not in the site so we need to copy
				// $if debug{println(" - @FN IS LINK: \n    abs:'$link_abs_path' \n    real:'$link_real_path'\n    site:'$site_abs_path'")}
				p_in.unlink()? // will transform link to become the file or dir it points too
				assert !p_in.is_link()
			} else {
				p_in.relink()? // will check that the link is on the file with the shortest path
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
					if ext == 'md' {
						site.page_new(mut p_in)?
					} else {
						site.file_image_remember(mut p_in)?
					}
				}
			}
		}
	}
}
