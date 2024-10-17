module doctree3

pub fn (mut tree Tree) process_defs() ! {
	for _, mut collection in tree.collections {
		for _, mut page in collection.pages {
			def_actions := page.get_def_actions()!
			if def_actions.len > 1 {
				collection.error(
					path: page.path
					msg: 'a page can have at most one def action'
					cat: .def
				)
			}

			if def_actions.len == 0 {
				continue
			}

			aliases := page.process_def_action(def_actions[0].id)!
			for alias in aliases {
				if alias in tree.defs {
					collection.error(
						path: page.path
						msg: 'alias ${alias} is already used'
						cat: .def
					)
					continue
				}

				tree.defs[alias] = page
			}
		}
	}

	for _, mut collection in tree.collections {
		for _, mut page in collection.pages {
			defs := page.get_def_names()!

			mut def_data := map[string][]string{}
			for def in defs {
				referenced_page := tree.defs[def] or {
					collection.error(path: page.path, msg: 'def ${def} is not defined', cat: .def)
					continue
				}

				def_data[def] = [referenced_page.key(), referenced_page.alias]
			}

			page.set_def_links(def_data)!
		}
	}
}
