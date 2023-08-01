module knowledgetree

import freeflowuniverse.crystallib.pathlib
import freeflowuniverse.crystallib.imagemagick
import freeflowuniverse.crystallib.params
import os

[params]
pub struct CollectionScannerArgs {
pub mut:
	path string
	heal bool // healing means we fix images, if selected will automatically load, remove stale links
	load bool
	git_url   string
	git_reset bool
	git_root  string
	git_pull  bool	
}

// walk over directory find dis with .site or .collection inside and add to the tree
// a path will not be added unless .collection is in the path of a collection dir 
pub fn (mut tree Tree) collections_scan(args CollectionScannerArgs) ! {
	// $if debug{println(" - collections find recursive: $path.path")}
	mut args := args_
	if args.git_url.len > 0 {
		mut gs := gittools.get(root: args.git_root)!
		mut gr := gs.repo_get_from_url(url: args.git_url, pull: args.git_pull, reset: args.git_reset)!
		args.path = gr.path_content_get()
	}

	if args.path.len < 3 {
		return error('Path needs to be not empty.')
	}
	mut path := pathlib.get_dir(args.path, false)!

	if path.is_dir() {
		if path.file_exists('.site') {
			// mv .site file to .collection file
			collectionfilepath1 := path.extend_file('.site')!
			collectionfilepath2 := path.extend_file('.collection')!
			os.mv(collectionfilepath1.path, collectionfilepath2.path)!
		}
		if path.file_exists('.collection') {
			mut name := path.name()
			mut collectionfilepath := path.file_get('.collection')!

			// now we found a tree we need to add
			content := collectionfilepath.read()!
			if content.trim_space() != '' {
				// means there are params in there
				mut params_ := params.parse(content)!
				if params_.exists('name') {
					name = params_.get('name')!
				}
			}
			println(' - collection new: ${collectionfilepath.path} name:${name}')
			tree.collection_new(path: path.path, name: name, heal: args.heal, load: args.load)!
			return
		}
		mut llist := path.list(recursive: false) or {
			return error('cannot list: ${path.path} \n${error}')
		}
		for mut p_in in llist {
			if p_in.is_dir() {
				if p_in.name().starts_with('.') || p_in.name().starts_with('_') {
					continue
				}

				tree.scan_recursive(path: p_in.path, heal: args.heal, load: args.load) or {
					msg := 'Cannot process recursive on ${p_in.path}\n${err}'
					// println(msg)
					return error(msg)
				}
			}
		}
	}
}
