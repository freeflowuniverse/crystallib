module doctree

import freeflowuniverse.crystallib.core.pathlib

import freeflowuniverse.crystallib.ui.console
import os
import freeflowuniverse.crystallib.core.texttools.regext

@[params]
pub struct TreeExportArgs {
pub mut:
	dest           string @[required]
	reset          bool = true
	keep_structure bool // wether the structure of the src collection will be preserved or not
	exclude_errors bool // wether error reporting should be exported as well
	production     bool = true
	toreplace string
	runactions bool
}

// export all collections to chosen directory .
// all names will be in name_fixed mode .
// all images in img/
pub fn (mut tree Tree) export(args_ TreeExportArgs) ! {
	console.print_header('export tree: name:${tree.name} to ${args_.dest}')
	mut args := args_

	if args.toreplace.len>0{
		mut ri := regext.regex_instructions_new()
		ri.add_from_text(args.toreplace)!
		tree.replacer=ri
	}

	tree.process_includes()!

	tree.process_macros()!
	
	console.print_header('EXPORT DEBUG')

	// mut c:=tree.collections['tfgridsimulation_farming'] or {panic("aaaa")}
	// mut p:=c.pages['node_1u'] or {panic("qqqq")}
	// println(p.doc()!)
	// if true{panic("sdsd")}

	mut path_src := pathlib.get_dir(path: '${args.dest}/src', create: true)!
	mut path_edit := pathlib.get_dir(path: '${args.dest}/.edit', create: true)!
	if !args.production {
		if args.reset {
			path_edit.empty()!
		}
	}

	if args.reset {
		path_src.empty()!
	}

	for name, mut collection in tree.collections {
		mut collection_linked_pages := []string{}
		console.print_green('export collection: name:${name}')
		dir_src := pathlib.get_dir(path: path_src.path + '/' + name, create: true)!

		if !args.production {
			collection.path.link('${path_edit.path}/${name}', true)!
		}

		mut cfile := pathlib.get_file(path: dir_src.path + '/.collection', create: true)! // will auto safe it
		cfile.write("name:${name} src:'${collection.path.path}'")!

		for _, mut page in collection.pages {
			dest := if args.keep_structure {
				relpath := page.path.path.trim_string_left(collection.path.path)
				'${dir_src.path}/${relpath}'
			} else {
				'${dir_src.path}/${page.name}.md'
			}
			console.print_debug('export page ${page.name} to ${dest}')
			mut mydoc := page.export(dest: dest,replacer:tree.replacer)!
			for linked_page in mydoc.linked_pages {
				if linked_page !in collection_linked_pages {
					collection_linked_pages << linked_page
				}
			}
		}

		for _, mut file in collection.files {
			mut d := '${dir_src.path}/img/${file.name}.${file.ext}'
			console.print_debug('export file ${d}')
			if args.reset || !os.exists(d) {
				file.copy(d)!
			}
		}

		for _, mut file in collection.images {
			mut d := '${dir_src.path}/img/${file.name}.${file.ext}'
			if args.reset || !os.exists(d) {
				console.print_debug('export image ${d}')
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


