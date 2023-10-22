module knowledgetree

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.texttools
import os
import freeflowuniverse.crystallib.baobab.smartid

[params]
pub struct TreeScannerArgs {
pub mut:
	name string = 'default' // name of tree
	path string
	heal bool // healing means we fix images, if selected will automatically load, remove stale links
	load bool = true
	// strict    bool // means we assume all dir's in root directory of scanning to be collections
	git_url   string
	git_reset bool
	git_root  string
	git_pull  bool
	cid smartid.CID
}

pub fn scan(args_ TreeScannerArgs) ! {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	lock knowledgetrees {
		mut tree := knowledgetrees[args.name] or { return error('cannot find tree: ${args.name}') }
		tree.scan(args)!
		knowledgetrees[args.name] = tree
		// knowledgetrees[args.name] or { return error('cannot find tree: ${args.name}') }.scan(args)!
	}

	lock knowledgetrees {
		mut tree := knowledgetrees[args.name] or { return error('cannot find tree: ${args.name}') }
		tree.heal(args)!
		knowledgetrees[args.name] = tree
	}
}

// walk over directory find dirs with .book or .collection inside and add to the tree
// a path will not be added unless .collection is in the path of a collection dir or .book in a book
pub fn (mut tree Tree) scan(args_ TreeScannerArgs) ! {
	// $if debug{println(" - collections find recursive: $path.path")}
	mut args := args_
	if args.git_url.len > 0 {
		args.path = gittools.code_get(
			coderoot: args.git_root
			url: args.git_url
			pull: args.git_pull
			reset: args.git_reset
			reload: false
		)!
	}

	if args.path.len < 3 {
		return error('Path needs to be not empty.')
	}
	mut path := pathlib.get_dir(args.path, false)!

	if path.is_dir() {
		mut name := path.name()
		if path.file_exists('.site') {
			// mv .site file to .collection file
			collectionfilepath1 := path.extend_file('.site')!
			collectionfilepath2 := path.extend_file('.collection')!
			os.mv(collectionfilepath1.path, collectionfilepath2.path)!
		}
		for type_of_file in ['.collection', '.book'] {
			if path.file_exists(type_of_file) {
				mut filepath := path.file_get(type_of_file)!

				// now we found a tree we need to add
				content := filepath.read()!
				if content.trim_space() != '' {
					// means there are params in there
					mut params_ := paramsparser.parse(content)!
					if params_.exists('name') {
						name = params_.get('name')!
					}
				}
				tree.logger.debug(' - ${type_of_file[1..]} new: ${filepath.path} name:${name}')
				match type_of_file {
					'.collection' {
						tree.collection_new(
							path: path.path
							name: name
							heal: args.heal
							load: args.load
						)!
						return
					}
					else {
						panic('not implemented: please add the new type to the match statement')
					}
				}
			}
		}

		// QUESTION: is this necessary?
		// if !args.strict {
		// 	for dir in path.dir_list()! {
		// 		// dont double count collections already added
		// 		if !dir.file_exists('.collection') || !dir.file_exists('.site') {
		// 			tree.collection_new(
		// 				path: dir.path
		// 				name: name
		// 				heal: args.heal
		// 				load: args.load
		// 			)!
		// 		}
		// 	}
		// }

		mut pl := path.list(recursive: false) or {
			return error('cannot list: ${path.path} \n${error}')
		}
		for mut p_in in pl.paths {
			if p_in.is_dir() {
				if p_in.name().starts_with('.') || p_in.name().starts_with('_') {
					continue
				}

				tree.scan(path: p_in.path, heal: args.heal, load: args.load) or {
					msg := 'Cannot process recursive on ${p_in.path}\n${err}'
					return error(msg)
				}
			}
		}
	}
}

// pub fn (mut tree Tree) get_external_assets() ! {
// 	tree.collection_new(name: '_external', path: '')!
// 	for key, mut collection in tree.collections {
// 		external_links := []markdowndocs.Link{}
// 		for link in external_links {
// 			if tree.collections.values().any(fn (mut it) {
// 				link.path.starts_with(mut it)
// 			})
// 			{
// 				// means that link external to collection exists in another collection belonging to tree, so skip
// 				continue
// 			}
// 			collection.page_new(link.path)
// 		}
// 	}
// }

// QUESTION: healing doesn't work in scanning, is it ok to separate?
pub fn (mut tree Tree) heal(args_ TreeScannerArgs) ! {
	mut args := args_
	if args.heal {
		for _, mut collection in tree.collections {
			if !args.load {
				collection.scan()!
			}
			collection.fix()!
		}
	}
}
