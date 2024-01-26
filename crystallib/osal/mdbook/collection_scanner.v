module mdbook

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.ui.console
import os

@[params]
pub struct CollectionScannerArgs {
pub mut:
	path      string
	git_url   string
	git_reset bool
	git_root  string
	git_pull  bool
}

// walk over directory find dirs with .collection inside
// ```
// path string
// git_url   string
// git_reset bool
// git_root  string
// git_pull  bool
// ```	
pub fn (mut book MDBook) collections_add(args_ CollectionScannerArgs) ! {
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
	mut path := pathlib.get_dir(path: args.path)!
	book.scan(mut path)!
}

fn (mut book MDBook) scan(mut path pathlib.Path) ! {
	if path.is_dir() {
		mut name := path.name()
		if path.file_exists('.collection') {
			mut filepath := path.file_get('.collection')!

			// now we found a tree we need to add
			content := filepath.read()!
			if content.trim_space() != '' {
				// means there are params in there
				mut params_ := paramsparser.parse(content)!
				if params_.exists('name') {
					name = params_.get('name')!
				}
			}
			console.print_header('Collection found: ${path.path} name:${name}')

			book.collection_add(name: name, path: path.path)!
			return
		}

		mut pl := path.list(recursive: false) or {
			return error('cannot list: ${path.path} \n${error}')
		}

		for mut p_in in pl.paths {
			if p_in.is_dir() {
				if p_in.name().starts_with('.') || p_in.name().starts_with('_') {
					continue
				}
				book.scan(mut p_in)!
			}
		}
	}
}
