module doctree3

import freeflowuniverse.crystallib.data.doctree3.collection.data

pub fn (mut tree Tree) process_defs() ! {
	for _, mut collection in tree.collections {
		for _, mut page in collection.pages {
			aliases := page.process_aliases() or {
				if err is data.PageMultiError {
					collection.add_page_multi_error(err)
					continue
				}

				return err
			}

			for alias in aliases {
				tree.defs[alias] = page
			}
		}
	}

	for _, mut collection in tree.collections {
		for _, mut page in collection.pages {
			page.process_def_pointers(tree.defs) or {
				if err is data.PageMultiError {
					collection.add_page_multi_error(err)
					continue
				}

				return err
			}
		}
	}
}
