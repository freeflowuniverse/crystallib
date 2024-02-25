module doctree

import freeflowuniverse.crystallib.ui.console

fn (tree Tree) process_page_includes(mut page Page, col_name string) ! {
	mut collection := tree.collection_get(col_name)!

	mut mydoc := page.doc()!
	mut res := mydoc.actionpointers(actor: 'wiki', name: 'include')
	if res.len > 0 {
		// means there is a wiki def defined
		for mut action_element in res {
			my_action := action_element.action
			action_element.action_processed = true
			name := my_action.params.get_default('page', '')!
			if name == '' {
				collection.error(
					path: page.path
					msg: "can't find 'page' param for include action: ${my_action}"
					cat: .include
				)
			}
			// handle includes from other collections
			if collection.page_exists(name) {
				mut mypage2 := collection.page_get(name)!
				if mypage2.key() == page.key() {
					collection.error(
						path: page.path
						msg: 'recursive include: ${name} for include action: ${my_action}'
						cat: .include
					)
					continue
				}
				tree.process_page_includes(mut mypage2, col_name)!
				mut mydoc2 := mypage2.doc()!
				action_element.content = mydoc2.markdown()
			} else {
				collection.error(
					path: page.path
					msg: "can't find page: ${name} for include action: ${my_action}"
					cat: .include
				)
			}
		}
	}
}

pub fn (mut tree Tree) process_includes() ! {
	tree.process_defs()! // process definitions, always first definitions	

	for collectionname, mut collection in tree.collections {
		// console.print_green("get includes for collection:${collectionname}")		
		for pagekey in collection.pages.keys() {
			mut page := collection.pages[pagekey] or { panic('bug') }
			console.print_green('Get includes for page ${page.key()}')
			// process include recursivly
			tree.process_page_includes(mut page, collectionname)!
		}
	}
}
