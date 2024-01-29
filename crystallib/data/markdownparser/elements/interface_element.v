module elements

import freeflowuniverse.crystallib.core.playbook
// import freeflowuniverse.crystallib.data.paramsparser

@[heap]
interface Element {
	markdown() string
	html() string
	actions(args ActionsGetArgs) []playbook.Action
	treeview_(prefix string, mut out []string)
	action_pointers(args ActionsGetArgs) []ActionPointer
	children_recursive() []Element
	children_recursive_(mut []Element)
mut:
	id        int
	content   string
	processed bool
	// params    paramsparser.Params
	type_name   string
	changed     bool
	trailing_lf bool
	children    []Element
	process() !int
	content_set(int, string)
	id_set(int) int
}

@[heap]
pub struct ActionPointer {
pub mut:
	action     playbook.Action
	element_id int
}
