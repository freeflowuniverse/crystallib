module doctree3

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.texttools.regext

@[params]
pub struct TreeExportArgs {
pub mut:
	dest           string @[required]
	reset          bool = true
	keep_structure bool // wether the structure of the src collection will be preserved or not
	exclude_errors bool // wether error reporting should be exported as well
	production     bool = true
	toreplace      string
}

// export all collections to chosen directory .
// all names will be in name_fixed mode .
// all images in img/
pub fn (mut tree Tree) export(args TreeExportArgs) ! {
	console.print_header('export tree: name:${tree.name} to ${args.dest}')
	if args.toreplace.len > 0 {
		mut ri := regext.regex_instructions_new()
		ri.add_from_text(args.toreplace)!
		tree.replacer = ri
	}

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

	tree.process_defs()!
	tree.process_includes()!
	tree.process_actions_and_macros()! // process other actions and macros

	file_paths := tree.generate_paths()!

	console.print_green('exporting collections')
	for _, mut collection in tree.collections {
		collection.export(
			path_src: path_src
			path_edit: path_edit
			file_paths: file_paths
			reset: args.reset
			keep_structure: args.keep_structure
			exclude_errors: args.exclude_errors
			production: args.production
			replacer: tree.replacer
		)!
	}
}

fn (mut t Tree) generate_paths() !map[string]string {
	mut paths := map[string]string{}
	for _, col in t.collections {
		for _, page in col.pages {
			paths['${col.name}:${page.name}.md'] = '${col.name}/${page.name}.md'
		}

		for _, image in col.images {
			paths['${col.name}:${image.file_name()}'] = '${col.name}/img/${image.file_name()}'
		}

		for _, file in col.files {
			paths['${col.name}:${file.file_name()}'] = '${col.name}/img/${file.file_name()}'
		}
	}

	return paths
}
