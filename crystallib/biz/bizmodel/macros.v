module bizmodel

import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console

pub fn (mut m BizModel) process_macros() ! {
	mut mdbook_source_path := pathlib.get_dir(path: m.params.mdbook_source, create: false)!

	mut pl := mdbook_source_path.list()!

	for path in pl.paths {
		console.print_debug(path)
		mut doc := markdownparser.new(path: path.path)!

		if true {
			c := doc.markdown()!
			console.print_debug('\n\n\n')
			console.print_debug(c)

			panic('S')
		}
	}
}
