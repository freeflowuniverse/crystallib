module doctree

import freeflowuniverse.crystallib.core.pathlib
import os

@[params]
pub struct TreeExportArgs {
pub mut:
	dest  string
	reset bool
}

// export all collections to chosen directory .
// all names will be in name_fixed mode .
// all images in img/
pub fn (mut tree Tree) export(args_ TreeExportArgs) ! {
	mut args := args_
	mut path := pathlib.get_dir(path: args.dest, create: true)!

	if args.reset {
		path.empty()!
	}

	for name, mut collection in tree.collections {
		dir := pathlib.get_dir(path: path.path + '/' + name, create: true)!
		pathlib.get_file(path: dir.path + '/.collection', create: true)! // will auto safe it

		for _, mut page in collection.pages {
			page.export(dest: '${dir.path}/${page.name}.md')!
		}

		for _, mut file in collection.files {
			mut d := '${dir.path}/img/${file.name}.${file.ext}'
			if args.reset || !os.exists(d) {
				file.copy(d)!
			}
		}

		for _, mut file in collection.images {
			mut d := '${dir.path}/img/${file.name}.${file.ext}'
			if args.reset || !os.exists(d) {
				file.copy(d)!
			}
		}
		collection.errors_report('${dir.path}/errors.md')!
	}
}
