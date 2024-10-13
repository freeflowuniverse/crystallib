module collection

import freeflowuniverse.crystallib.data.markdownparser.elements { Action, Doc }
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.core.texttools
// import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.playmacros

pub fn (mut page Page) doc() !&Doc {
	mut mydoc := page.doc_ or {
		mut mydoc2 := markdownparser.new(path: page.path.path, collection_name: page.collection_name)!
		&mydoc2
	}

	page.doc_ = mydoc
	return mydoc
}

// reparse the markdown
pub fn (mut page Page) doc_process() ! {
	mut mydoc := page.doc()!
	mut nrmacros := 0
	for mut element in mydoc.children_recursive() {
		if mut element is Action {
			if element.action.actiontype == .macro {
				content := playmacros.play_macro(element.action)!
				nrmacros += 1
				if content.len > 0 {
					element.content = content
				}
			}
		}
	}
	if nrmacros > 0 {
		c := mydoc.markdown()!
		mut doc := markdownparser.new(content: c)!
		page.doc_ = &doc
		// recursive, make sure we have all macro's processed
		page.doc_process()!
	}
}
