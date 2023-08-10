module knowledgetree

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.texttools

[params]
struct CollectionNewArgs {
mut:
	name      string [required]
	path      string [required]
	heal      bool // healing means we fix images, if selected will automatically load, remove stale links
	load      bool = true
}

// get a new collection
pub fn (mut tree Tree) collection_new(args_ CollectionNewArgs) !&Collection {
	mut args := args_
	args.name = texttools.name_fix_no_underscore_no_ext(args.name)

	mut pp := pathlib.get_dir(args.path, false)! //will raise error if path doesn't exist
	mut collection := &Collection{
		name: args.name
		path: pp
		heal: args.heal
		tree: &tree
	}
	if args.load || args.heal {
		collection.scan()!
	}
	if args.heal {
		collection.fix()!
	}
	println("ALL PAGES: ${collection.pages}")

	tree.collections[collection.name] = collection
	return collection
}

// path is the full path
fn (mut collection Collection) scan_internal(mut p pathlib.Path) ! {
	$if debug {
		println('--- scan ${p.path}')
	}
	mut llist := p.list(recursive: false)!
	for mut p_in in llist {
		// println("--- SCAN SUB:\n$p_in")
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
				collection.error(path: p_in, msg: 'a markdown file should not be linked', cat: .unknown)
				continue
			}
			if !link_real_path.starts_with(collection_abs_path) {
				// means we are not in the collection so we need to copy
				// $if debug{println(" - @FN IS LINK: \n    abs:'$link_abs_path' \n    real:'$link_real_path'\n    collection:'$collection_abs_path'")}
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
						collection.page_new(mut p_in)!
					} else {
						collection.file_image_remember(mut p_in)!
					}
				}
			}
		}
	}
}
