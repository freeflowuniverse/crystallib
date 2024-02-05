module doctree

import freeflowuniverse.crystallib.core.pathlib
import os

@[params]
pub struct TreeExportArgs {
pub mut:
	dest  string @[required]
	reset bool = true
}

// export all collections to chosen directory .
// all names will be in name_fixed mode .
// all images in img/
pub fn (mut tree Tree) export(args_ TreeExportArgs) ! {
	mut args := args_

	mut path_src := pathlib.get_dir(path: "${args.dest}/src", create: true)!
	mut path_edit := pathlib.get_dir(path: "${args.dest}/edit", create: true)!

	if args.reset {
		path_src.empty()!
		path_edit.empty()!
	}

	for name, mut collection in tree.collections {
		dir_src := pathlib.get_dir(path: path_src.path + '/' + name, create: true)!

		collection.path.link("${path_edit.path}/${name}",true)!

		mut cfile:=pathlib.get_file(path: dir_src.path + '/.collection', create: true)! // will auto safe it
		cfile.write("name:${name} src:'${collection.path.path}'")!

		for _, mut page in collection.pages {
			page.export(dest: '${dir_src.path}/${page.name}.md')!
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
		collection.errors_report('${dir_src.path}/errors.md')!
	}
}
