module doctree

import freeflowuniverse.crystallib.data.markdownparser.elements { Action }
import freeflowuniverse.crystallib.data.markdownparser
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.core.playmacros
import os

@[params]
pub struct MacroGetArgs {
pub mut:
	actor string
	name  string
}

pub fn (mut tree Tree) get_actions(args_ MacroGetArgs) ![]&Action {
	//console.print_green('get actions for tree: name:${tree.name}')
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

	console.print_green('process macros for tree: name:${tree.name}')

	//first process the generic actions, which can be executed as is
	mut plbook := playbook.new()!
	for element_action in tree.get_actions()!{
		plbook.actions << &element_action.action
	}

	playmacros.play(mut plbook)!

	//now get specific actions which need to return content
	for _, mut collection in tree.collections {	
		for _, mut page in collection.pages {
			mut mydoc := page.doc()!
			for mut element in mydoc.children_recursive() {
				if mut element is Action {
					content:=playmacros.playmacro(element.action)!
					if content.len>0{
						element.content = content
					}
				}
			}
		}
	}

}



