module collection

import freeflowuniverse.crystallib.core.pathlib

// walk over one specific collection, find all files and pages
pub fn (mut collection Collection) scan() ! {
	collection.scan_directory(mut collection.path)!
}

// path is the full path
fn (mut collection Collection) scan_directory(mut p pathlib.Path) ! {
	mut entry_list := p.list(recursive: false)!
	for mut entry in entry_list.paths {
		if !entry.exists() {
			collection.error(
				path: entry
				msg: 'Entry ${entry.name()} does not exists'
				cat: .unknown
			)
			continue
		}

		if mut entry.is_link() {
			link_real_path := entry.realpath() // this is with the symlink resolved
			collection_abs_path := collection.path.absolute()
			if entry.extension_lower() == 'md' {
				// means we are linking pages,this should not be done, need or change
				collection.error(
					path: entry
					msg: 'Markdown files (${entry.path}) must not be linked'
					cat: .unknown
				)
				continue
			}

			if !link_real_path.starts_with(collection_abs_path) {
				// means we are not in the collection so we need to copy
				entry.unlink()! // will transform link to become the file or dir it points too
			} else {
				// TODO: why do we need this?
				entry.relink()! // will check that the link is on the file with the shortest path
			}
		}

		if collection.should_skip_entry(mut entry) {
			continue
		}

		if entry.is_dir() {
			collection.scan_directory(mut entry)!
			continue
		}

		ext := entry.extension().to_lower()
		if ext != '' {
			// only process files which do have extension
			if ext == 'md' {
				collection.page_new(mut entry)!
			} else {
				collection.file_image_remember(mut entry)!
			}
		}
	}
}

fn (mut c Collection) should_skip_entry(mut entry pathlib.Path) bool {
	entry_name := entry.name()

	// entries that start with . or _ are ignored
	if entry_name.starts_with('.') || entry_name.starts_with('_') {
		return true
	}

	if entry.cat == .linkfile {
		// means we link to a file which is in the folder, so can be loaded later, nothing to do here
		return true
	}

	if entry.is_dir() && entry_name.starts_with('gallery_') {
		return true
	}

	if entry_name.to_lower() == 'defs.md' {
		return true
	}

	if entry_name.contains('.test') {
		return true
	}

	if entry.path.starts_with('sidebar') {
		return true
	}

	return false
}
