module doctree

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import os
import freeflowuniverse.crystallib.core.texttools

pub fn (mut tree Tree) process_defs() ! {
	if tree.defs.len > 0 {
		return
	}

	for name, mut collection in tree.collections {
		// console.print_green("get defs for collection:${name}")		
		for pagekey in collection.pages.keys() {
			mut page := collection.pages[pagekey] or { panic('bug') }
			// console.print_debug("get defs for page:${page.key()}")
			mut mydoc := page.doc()!
			mut res := mydoc.actionpointers(actor: 'wiki', name: 'def')
			if res.len > 0 {
				// means there is a wiki def defined
				for mut action_element in res {
					my_action := action_element.action
					page.alias = my_action.params.get_default('name', '')!
					if page.alias == '' {
						page.alias = mydoc.header_name()!
					}
					action_element.action_processed = true
					action_element.content = ''
					for mut alias in my_action.params.get_list('alias')! {
						if alias.to_lower().ends_with('.md') {
							// remove the .md at end
							alias = alias[0..name.len - 3]
						}
						alias2 := texttools.name_fix(alias).replace('_', '')
						if alias2 in tree.defs {
							collection.error(
								path: page.path
								msg: 'def double defined: ${alias}'
								cat: .def
							)
						} else {
							tree.defs[alias2] = page
						}
					}
				}
			}
		}
	}

	for collection_name in tree.collections.keys() {
		mut collection := tree.collections[collection_name] or { panic('bug') }
		console.print_green('process defs for collection:${collection_name}')
		for name in collection.pages.keys() {
			mut mypage := collection.pages[name] or { panic('bug') }
			mut mydoc := mypage.doc()!
			for mut defitem in mydoc.defpointers() {
				println(defitem)
				defname := defitem.nameshort
				assert defname.len>0
				console.print_green('defpointer:${defitem}')
				if defname in tree.defs {
					mut mydef_page := tree.defs[defname] or { panic('bug') }
					mydef_page.doc()!
					defitem.pagekey = mydef_page.key()
					defitem.pagename = mydef_page.alias
					defitem.process_link()!
				} else {
					collection.error(
						path: mypage.path
						msg: "def not found: '${defname}'"
						cat: .def
					)
				}
			}

			mydoc.process()!
		}
	}

	// panic("macro")					
	// for macro in tree.get_macros(name:"def",actor:"wiki")!{
	// 	println(macro)
	// 	if true{
	// 		panic("macro")
	// 	}
	// }
}
