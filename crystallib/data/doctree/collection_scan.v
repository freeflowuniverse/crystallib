module doctree

import freeflowuniverse.crystallib.core.pathlib

// walk over one specific collection, find all files and pages
pub fn (mut collection Collection) scan() ! {
	$if debug {
		println('load collection: ${collection.name} - ${collection.path.path}')
	}
	collection.scan_internal(mut collection.path)!
	$if debug {
		println('scan done')
	}
}

// path is the full path
fn (mut collection Collection) scan_internal(mut p pathlib.Path) ! {
	$if debug {
		println('scan ${p.path}')
	}
	mut pl := p.list(recursive: false)!
	for mut p_in in pl.paths {
		if p_in.exists() == false {
			collection.error(path: p_in, msg: 'probably a broken link', cat: .unknown)
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
			collection_abs_path := collection.path.absolute()
			if p_in.extension_lower() == 'md' {
				// means we are linking pages,this should not be done, need or change
				collection.error(
					path: p_in
					msg: 'a markdown file should not be linked'
					cat: .unknown
				)
				continue
			}
			if !link_real_path.starts_with(collection_abs_path) {
				// means we are not in the collection so we need to copy
				p_in.unlink()! // will transform link to become the file or dir it points too
				assert !p_in.is_link()
			} else {
				p_in.relink()! // will check that the link is on the file with the shortest path
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
				// } else if p_name == 'collections' {
				// 	p_in.delete()!
				// 	continue
			} else {
				collection.scan_internal(mut p_in)!
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
						// p_in.sids_replace(collection.tree.cid)! // replace all found id:*** //TODO: kristof check
						collection.page_new(mut p_in)!
					} else {
						collection.file_image_remember(mut p_in)!
					}
				}
			}
		}
	}
}
