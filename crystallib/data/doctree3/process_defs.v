module doctree3

import freeflowuniverse.crystallib.core.texttools

pub fn (mut tree Tree) process_defs() ! {
	if tree.defs.len > 0 {
		return
	}

	for name, mut collection in tree.collections {
		for _, mut page in collection.pages {
			mut doc := page.doc()!
			mut def_actions := doc.actionpointers(actor: 'wiki', name: 'def')
			for mut action_element in def_actions {
				def_action := action_element.action
				page.alias = def_action.params.get_default('name', '')!
				if page.alias == '' {
					page.alias = doc.header_name()!
				}

				action_element.action_processed = true
				action_element.content = ''
				for mut alias in def_action.params.get_list('alias')! {
					if alias.to_lower().ends_with('.md') {
						// remove the .md at end
						alias = alias[0..name.len - 3]
					}

					alias = texttools.name_fix(alias).replace('_', '')
					if alias in tree.defs {
						collection.error(
							path: page.path
							msg: 'def already exists: ${alias}'
							cat: .def
						)
						continue
					}

					tree.defs[alias] = page
				}
			}
		}
	}

	for _, mut collection in tree.collections {
		for _, mut page in collection.pages {
			mut doc := page.doc()!
			for mut defitem in doc.defpointers() {
				defname := defitem.nameshort

				mut def_page := tree.defs[defname] or {
					collection.error(
						path: page.path
						msg: "def not found: '${defname}'"
						cat: .def
					)
					continue
				}

				defitem.pagekey = def_page.key()
				defitem.pagename = def_page.alias
				defitem.process_link()!
			}

			doc.process()!
		}
	}
}
