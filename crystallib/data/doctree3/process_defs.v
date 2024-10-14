module doctree3

pub fn (mut tree Tree) process_defs() ! {
	for _, mut collection in tree.collections {
		for _, mut page in collection.pages {
			aliases, def_errs := page.process_aliases()!
			for err in def_errs {
				collection.error(
					path: page.path
					msg: 'error processing page ${page.path} aliases: ${err}'
					cat: .def
				)
			}

			for alias in aliases {
				tree.defs[alias] = page
			}
		}
	}

	for _, mut collection in tree.collections {
		for _, mut page in collection.pages {
			def_errs := page.process_def_pointers(tree.defs)!

			for err in def_errs {
				collection.error(
					path: page.path
					msg: 'error processing page ${page.path} deffs: ${err}'
					cat: .def
				)
			}
		}
	}
}
