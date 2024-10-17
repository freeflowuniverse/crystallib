module doctree3

import freeflowuniverse.crystallib.data.doctree3.collection.data
import freeflowuniverse.crystallib.data.doctree3.pointer

fn (tree Tree) process_page_includes_recursive(mut current_page data.Page, mut vis map[string]bool) ! {
	vis[current_page.key()] = true

	current_collection_name := current_page.collection_name
	mut current_collection := tree.collections[current_collection_name] or {
		return error('collection with name ${current_collection_name} not found')
	}

	include_action_elements := current_page.get_include_actions()!
	for action_element in include_action_elements {
		include_action := action_element.action
		current_page.set_action_element_to_processed(action_element.id)!

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
				msg: 'circular include: ${page_pointer_str} for include action: ${include_action}'
				cat: .circular_import
			)
			continue
		}

		tree.process_page_includes_recursive(mut include_page, mut vis)!
		include_markdown := include_page.get_markdown()!
		current_page.set_element_content_no_reparse(action_element.id, include_markdown)!
	}
}

fn (mut tree Tree) process_includes() ! {
	tree.process_defs()! // process definitions, always first definitions	

	for _, mut collection in tree.collections {
		for _, mut page in collection.pages {
			mut vis := map[string]bool{}
			mut p := page
			tree.process_page_includes_recursive(mut p, mut vis)!
		}
	}
}
