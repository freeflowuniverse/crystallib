module doctree

import freeflowuniverse.crystallib.core.pathlib

// walk over one specific playbook, find all files and pages
pub fn (mut playbook Collection) scan() ! {
	$if debug {
		println('load playbook: ${playbook.name} - ${playbook.path.path}')
	}
	playbook.scan_internal(mut playbook.path)!
	$if debug {
		println('scan done')
	}
}

// path is the full path
fn (mut playbook Collection) scan_internal(mut p pathlib.Path) ! {
	$if debug {
		println('scan ${p.path}')
	}
	mut pl := p.list(recursive: false)!
	for mut p_in in pl.paths {
		if p_in.exists() == false {
			// links are ignored in p.list()
			// this should probably only happen if file was deleted midway
			// between list() call and the exists() call
			playbook.error(path: p_in, msg: 'probably a broken link', cat: .unknown)
			continue // means broken link
		}
		p_name := p_in.name()
		if p_name.starts_with('.') {
			continue
		} else if p_name.starts_with('_') {
			continue
		}

		// Q: list ignores links, this can't happen, no?
		// Q: a path can't b both, a link and a file, no? maybe it was intended to be ||
		if mut p_in.is_link() && p_in.is_file() {
			link_real_path := p_in.realpath() // this is with the symlink resolved
			playbook_abs_path := playbook.path.absolute()
			if p_in.extension_lower() == 'md' {
				// means we are linking pages,this should not be done, need or change
				playbook.error(
					path: p_in
					msg: 'a markdown file should not be linked'
					cat: .unknown
				)
				continue
			}
			if !link_real_path.starts_with(playbook_abs_path) {
				// means we are not in the playbook so we need to copy
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
				// } else if p_name == 'playbooks' {
				// 	p_in.delete()!
				// 	continue
			} else {
				playbook.scan_internal(mut p_in)!
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
						// p_in.sids_replace(playbook.tree.cid)! // replace all found id:*** //TODO: kristof check
						playbook.page_new(mut p_in)!
					} else {
						playbook.file_image_remember(mut p_in)!
					}
				}
			}
		}
	}
}
