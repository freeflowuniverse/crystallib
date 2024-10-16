module collection

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools.regext
import os

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

pub fn (mut c Collection) export(args CollectionExportArgs) ! {
	dir_src := pathlib.get_dir(path: args.path_src.path + '/' + c.name, create: true)!
	if !args.production {
		c.path.link('${args.path_edit.path}/${c.name}', true)!
	}

	mut cfile := pathlib.get_file(path: dir_src.path + '/.collection', create: true)! // will auto save it
	cfile.write("name:${c.name} src:'${c.path.path}'")!

	c.export_pages(
		dir_src: dir_src
		keep_structure: args.keep_structure
		replacer: args.replacer
	)!
	c.export_files(dir_src, args.reset)!
	c.export_images(dir_src, args.reset)!
	c.export_linked_pages(dir_src)!

	if !args.exclude_errors {
		c.errors_report('${dir_src.path}/errors.md')!
	}
}

@[params]
pub struct ExportPagesArgs {
pub mut:
	dir_src        pathlib.Path
	keep_structure bool // wether the structure of the src collection will be preserved or not
	replacer       ?regext.ReplaceInstructions
}

fn (mut c Collection) export_pages(args ExportPagesArgs) ! {
	for _, mut page in c.pages {
		dest := if args.keep_structure {
			relpath := page.path.path.trim_string_left(c.path.path)
			'${args.dir_src.path}/${relpath}'
		} else {
			'${args.dir_src.path}/${page.name}.md'
		}

		page.export(dest: dest, replacer: args.replacer)!
	}
}

fn (mut c Collection) export_files(dir_src pathlib.Path, reset bool) ! {
	for _, mut file in c.files {
		mut d := '${dir_src.path}/img/${file.name}.${file.ext}'
		if reset || !os.exists(d) {
			file.copy(d)!
		}
	}
}

fn (mut c Collection) export_images(dir_src pathlib.Path, reset bool) ! {
	for _, mut file in c.images {
		mut d := '${dir_src.path}/img/${file.name}.${file.ext}'
		if reset || !os.exists(d) {
			file.copy(d)!
		}
	}
}

fn (mut c Collection) export_linked_pages(dir_src pathlib.Path) ! {
	collection_linked_pages := c.get_collection_linked_pages()!
	mut linked_pages_file := pathlib.get_file(path: dir_src.path + '/.linkedpages', create: true)!
	linked_pages_file.write(collection_linked_pages.join_lines())!
}

fn (mut c Collection) get_collection_linked_pages() ![]string {
	mut linked_pages_set := map[string]bool{}
	for _, mut page in c.pages {
		for linked_page in page.get_linked_pages()! {
			linked_pages_set[linked_page] = true
		}
	}

	return linked_pages_set.keys()
}
