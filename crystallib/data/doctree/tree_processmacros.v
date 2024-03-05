module doctree

import freeflowuniverse.crystallib.data.markdownparser.elements { Action }
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
// import freeflowuniverse.crystallib.core.playbook
import os

@[params]
pub struct MacroGetArgs {
pub mut:
	actor string
	name  string
}

pub fn (mut tree Tree) get_macros(args_ MacroGetArgs) ![]&Action {
	console.print_green('get actions for tree: name:${tree.name}')
	mut args := args_
	mut res := []&Action{}
	for _, mut collection in tree.collections {
		// console.print_green("export collection: name:${name}")		
		for _, mut page in collection.pages {
			mut mydoc := page.doc()!
			res << mydoc.actionpointers(actor: args.actor, name: args.name)
		}
	}
	return res
}
