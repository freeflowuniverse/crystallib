module doctree

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.texttools
import os
import freeflowuniverse.crystallib.baobab.smartid

@[params]
pub struct TreeScannerArgs {
pub mut:
	path      string
	heal      bool // healing means we fix images, if selected will automatically load, remove stale links
	git_url   string
	git_reset bool
	git_root  string
	git_pull  bool
	load      bool = true // means we scan automatically the added playbook
}

// walk over directory find dirs with .book or .playbook inside and add to the tree .
// a path will not be added unless .playbook is in the path of a playbook dir or .book in a book
// ```
// path string
// heal bool // healing means we fix images, if selected will automatically load, remove stale links
// git_url   string
// git_reset bool
// git_root  string
// git_pull  bool
// ```	
pub fn (mut tree Tree) scan(args_ TreeScannerArgs) ! {
	// $if debug{println(" - playbooks find recursive: $path.path")}
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

	if path.is_dir() {
		mut name := path.name()
		if path.file_exists('.site') {
			// mv .site file to .playbook file
			playbookfilepath1 := path.extend_file('.site')!
			playbookfilepath2 := path.extend_file('.playbook')!
			os.mv(playbookfilepath1.path, playbookfilepath2.path)!
		}
		for type_of_file in ['.playbook', '.book'] {
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
					'.playbook' {
						tree.playbook_new(
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

	if args.heal {
		tree.heal()!
	}
}

pub fn (mut tree Tree) heal() ! {
	for _, mut playbook in tree.playbooks {
		playbook.fix()!
	}
}

// pub fn (mut tree Tree) get_external_assets() ! {
// 	tree.playbook_new(name: '_external', path: '')!
// 	for key, mut playbook in tree.playbooks {
// 		external_links := []markdownparser.Link{}
// 		for link in external_links {
// 			if tree.playbooks.values().any(fn (mut it) {
// 				link.path.starts_with(mut it)
// 			})
// 			{
// 				// means that link external to playbook exists in another playbook belonging to tree, so skip
// 				continue
// 			}
// 			playbook.page_new(link.path)
// 		}
// 	}
// }
