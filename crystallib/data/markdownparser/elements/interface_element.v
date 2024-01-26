module elements

import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.data.paramsparser

interface Element {
	markdown() string
	html() string
	actions() []playbook.Action
mut:
	id        int
	content   string
	processed bool
	params    paramsparser.Params
	type_name string
	changed   bool
	children  []Element
	process(mut doc Doc) !int
	treeview_(prefix string, mut out []string)
}
