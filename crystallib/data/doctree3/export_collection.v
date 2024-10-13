module doctree3

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.doctree3.collection
import freeflowuniverse.crystallib.ui.console
import os
import freeflowuniverse.crystallib.core.texttools.regext

@[params]
pub struct CollectionExportArgs {
pub mut:
	path_src       pathlib.Path                @[required]
	path_edit      pathlib.Path                @[required]
	reset          bool = true
	keep_structure bool // wether the structure of the src collection will be preserved or not
	exclude_errors bool // wether error reporting should be exported as well
	production     bool = true
	replacer       ?regext.ReplaceInstructions
}

pub fn (mut t Tree) export_collection(mut c collection.Collection, args CollectionExportArgs) ! {
	dir_src := pathlib.get_dir(path: args.path_src.path + '/' + c.name, create: true)!
	if !args.production {
		c.path.link('${args.path_edit.path}/${c.name}', true)!
	}

	mut cfile := pathlib.get_file(path: dir_src.path + '/.collection', create: true)! // will auto safe it
	cfile.write("name:${c.name} src:'${c.path.path}'")!

	t.export_collection_pages(mut c,
		dir_src: dir_src
		keep_structure: args.keep_structure
		replacer: args.replacer
	)!
	t.export_collection_files(mut c, dir_src, args.reset)!
	t.export_collection_images(mut c, dir_src, args.reset)!
	t.export_collection_linked_pages(mut c, dir_src)!

	if !args.exclude_errors {
		c.errors_report('${dir_src.path}/errors.md')!
	}
}

fn (t Tree) export_collection_files(mut c collection.Collection, dir_src pathlib.Path, reset bool) ! {
	for _, mut file in c.files {
		mut d := '${dir_src.path}/img/${file.name}.${file.ext}'
		if reset || !os.exists(d) {
			file.copy(d)!
		}
	}
}

fn (t Tree) export_collection_images(mut c collection.Collection, dir_src pathlib.Path, reset bool) ! {
	for _, mut file in c.images {
		mut d := '${dir_src.path}/img/${file.name}.${file.ext}'
		if reset || !os.exists(d) {
			console.print_debug('export image ${d}')
			file.copy(d)!
		}
	}
}

fn (t Tree) export_collection_linked_pages(mut c collection.Collection, dir_src pathlib.Path) ! {
	collection_linked_pages := t.get_collection_linked_pages(mut c)!
	mut linked_pages_file := pathlib.get_file(path: dir_src.path + '/.linkedpages', create: true)!
	linked_pages_file.write(collection_linked_pages.join_lines())!
}

fn (t Tree) get_collection_linked_pages(mut c collection.Collection) ![]string {
	mut linked_pages_set := map[string]bool{}
	for _, mut page in c.pages {
		mut mydoc := page.doc()!
		for linked_page in mydoc.linked_pages {
			linked_pages_set[linked_page] = true
		}
	}

	return linked_pages_set.keys()
}
