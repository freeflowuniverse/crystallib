module doctree

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import os
import freeflowuniverse.crystallib.core.texttools

@[params]
pub struct TreeExportArgs {
pub mut:
	dest  string @[required]
	reset bool = true
	keep_structure bool // wether the structure of the src collection will be preserved or not
	exclude_errors bool // wether error reporting should be exported as well
}

// export all collections to chosen directory .
// all names will be in name_fixed mode .
// all images in img/
pub fn (mut tree Tree) export(args_ TreeExportArgs) ! {
	console.print_green('export tree: name:${tree.name} to ${args_.dest}')
	mut args := args_

	tree.process_includes()! // process definitions (will also do defs)

	mut path_src := pathlib.get_dir(path: '${args.dest}/src', create: true)!
	mut path_edit := pathlib.get_dir(path: '${args.dest}/edit', create: true)!

	if args.reset {
		path_src.empty()!
		path_edit.empty()!
	}

	for name, mut collection in tree.collections {
		mut collection_linked_pages := []string{}
		console.print_green('export collection: name:${name}')
		dir_src := pathlib.get_dir(path: path_src.path + '/' + name, create: true)!

		collection.path.link('${path_edit.path}/${name}', true)!

		mut cfile := pathlib.get_file(path: dir_src.path + '/.collection', create: true)! // will auto safe it
		cfile.write("name:${name} src:'${collection.path.path}'")!

		for _, mut page in collection.pages {
			dest := if args.keep_structure {
				relpath := page.path.path.trim_string_left(collection.path.path)
				'${dir_src.path}/${relpath}'
			} else {'${dir_src.path}/${page.name}.md'}
			mut mydoc:=page.export(dest: dest)!
			for linked_page in mydoc.linked_pages{
				if !(linked_page in collection_linked_pages){
					collection_linked_pages<<linked_page
				}
			}
		}

		for _, mut file in collection.files {
			mut d := '${dir_src.path}/img/${file.name}.${file.ext}'
			if args.reset || !os.exists(d) {
				file.copy(d)!
			}
		}

		for _, mut file in collection.images {
			mut d := '${dir_src.path}/img/${file.name}.${file.ext}'
			if args.reset || !os.exists(d) {
				file.copy(d)!
			}
		}

		if !args.exclude_errors {
			collection.errors_report('${dir_src.path}/errors.md')!
		}

		mut linked_pages_file := pathlib.get_file(path: dir_src.path + '/.linkedpages', create: true)!
		linked_pages_file.write(collection_linked_pages.join_lines())!
	}
}
