module doctree

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import os
import freeflowuniverse.crystallib.core.texttools


pub fn (mut tree Tree) process_includes() ! {

	for name, mut collection in tree.collections {
		// console.print_green("get includes for collection:${name}")		
		for pagekey in collection.pages.keys() {
			mut page := collection.pages[pagekey] or {panic('bug')}
			// console.print_debug("get includes for page:${page.key()}")
			mut mydoc := page.doc()!
			mut res:=mydoc.actionpointers(actor:"wiki",name:"include")
			if res.len>0{
				//means there is a wiki def defined
				for mut action_element in res{
					my_action:=action_element.action
					action_element.action_processed=true
					name = my_action.params.get_default("name","")!
					if name==""{
						collection.error(path:page.path,msg:"can't find name for include action: ${action_element}",cat:.include)
					}
					if tree.page_exists(name){
						mut mypage2:=tree.page_get(name)!
						mut mydoc2 := mypage.doc()!
						mydoc2.markdown()!

					}else{
						collection.error(path:page.path,msg:"can't find page: ${name} for include action: ${action_element}",cat:.include)						
					}

				}
			}
		}
	}


}