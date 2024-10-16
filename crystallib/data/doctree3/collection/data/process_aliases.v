module data

import freeflowuniverse.crystallib.core.texttools

// TODO: use a custom error for pages
pub fn (mut page Page) process_aliases() ![]string {
	mut errs := PageMultiError{}
	mut aliases := map[string]bool{}

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
		page.changed = true
		for mut alias in def_action.params.get_list('alias')! {
			if alias.to_lower().ends_with('.md') {
				// remove the .md at end
				alias = alias[0..page.collection_name.len - 3]
			}

			alias = texttools.name_fix(alias).replace('_', '')
			if alias in aliases {
				errs.errs << PageError{
					path: page.path
					msg: 'def ${alias} already exists in page ${page.path.path}'
					cat: .def
				}
				continue
			}

			aliases[alias] = true
		}
	}

	if errs.errs.len > 0 {
		return errs
	}

	return aliases.keys()
}
