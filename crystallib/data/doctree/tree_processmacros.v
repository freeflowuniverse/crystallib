module doctree

import freeflowuniverse.crystallib.data.markdownparser.elements { Action }
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.core.playmacros

@[params]
pub struct MacroGetArgs {
pub mut:
	actor string
	name  string
}

pub fn (mut tree Tree) get_actions(args_ MacroGetArgs) ![]&Action {
	// console.print_green('get actions for tree: name:${tree.name}')
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

pub fn (mut tree Tree) process_macros() ! {
	console.print_green('process actions & macros for tree:\'${tree.name}\'')

	// first process the generic actions, which can be executed as is
	mut plbook := playbook.new()!
	for element_action in tree.get_actions()! {
		plbook.actions << &element_action.action
	}

	playmacros.play(mut plbook)!

	for _, mut collection in tree.collections {
		for _, mut page in collection.pages {
			page.doc_process()!
		}
	}
}
