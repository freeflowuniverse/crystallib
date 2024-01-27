module elements

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.data.paramsparser

interface Element {
	markdown() string
	html() string
	actions(args ActionsGetArgs) []playbook.Action
	treeview_(prefix string, mut out []string)
mut:
	id        int
	content   string
	processed bool
	// params    paramsparser.Params
	type_name string
	changed   bool
	trailing_lf bool
	children  []Element

	action_pointers(args ActionsGetArgs) []ActionPointer
	process() !int
}

pub struct ActionPointer{
pub mut:
	action playbook.Action
	doc_element &Element @[skip; str: skip]
}