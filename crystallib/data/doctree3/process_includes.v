module doctree3

import freeflowuniverse.crystallib.data.doctree3.collection.page
import freeflowuniverse.crystallib.data.doctree3.pointer

fn (tree Tree) process_page_includes_recursive(mut current_page page.Page, mut vis map[string]bool) ! {
	vis[current_page.key()] = true

	current_collection_name := current_page.collection_name
	mut current_collection := tree.collections[current_collection_name] or {
		return error('collection with name ${current_collection_name} not found')
	}

	mut current_doc := current_page.doc()!
	mut include_action_elements := current_doc.actionpointers(actor: 'wiki', name: 'include')

	for mut action_element in include_action_elements {
		include_action := action_element.action
		action_element.action_processed = true

		mut page_pointer_str := include_action.params.get('page') or {
			current_collection.error(
				path: current_page.path
				msg: 'include action with no page param: ${include_action}'
				cat: .include
			)
			continue
		}

		// handle includes
		page_pointer := pointer.pointer_new(page_pointer_str) or {
			current_collection.error(
				path: current_page.path
				msg: 'invalid include page pointer ${page_pointer_str}: ${err}'
			)
			continue
		}

		mut include_collection := current_collection
		if page_pointer.collection != '' {
			include_collection = tree.collections[page_pointer.collection] or {
				current_collection.error(
					path: current_page.path
					msg: 'include page collection ${page_pointer.collection} not found'
				)
				continue
			}
		}

		mut include_page := include_collection.pages[page_pointer.name] or {
			include_collection.error(
				path: current_page.path
				msg: "can't find page: ${page_pointer.name} for include action: ${include_action}"
				cat: .include
			)
			continue
		}

		if vis[include_page.key()] {
			include_collection.error(
				path: current_page.path
				msg: 'recursive include: ${page_pointer_str} for include action: ${include_action}'
				cat: .include
			)
			continue
		}

		tree.process_page_includes_recursive(mut include_page, mut vis)!
		mut include_doc := include_page.doc()!

		action_element.content = include_doc.markdown()!
		current_doc.changed = true
	}
}

pub fn (mut tree Tree) process_includes() ! {
	tree.process_defs()! // process definitions, always first definitions	

	for _, mut collection in tree.collections {
		for _, mut page in collection.pages {
			mut vis := map[string]bool{}
			tree.process_page_includes_recursive(mut page, mut vis)!
		}
	}
}
