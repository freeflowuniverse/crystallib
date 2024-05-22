module elements

import freeflowuniverse.crystallib.core.playbook

// NOT USED FOR NOW

@[heap]
pub struct Empty {
pub mut:
	id        int
	content   string
	processed bool
	type_name string
	changed   bool
	// trailing_lf bool
	children []&Element
}

pub fn (mut self Empty) process() !int {
	return 0
}

pub fn (mut self Empty) markdown() !string {
	return ''
}

pub fn (mut self Empty) pug() !string {
	return ''
}

pub fn (mut self Empty) html() !string {
	return ''
}

pub fn (mut self Empty) treeview_(prefix string, mut out []string) {
}

pub fn (mut self Empty) children_recursive() []&Element {
	return []&Element{}
}

pub fn (mut self Empty) children_recursive_(mut e []&Element) {	
}

pub fn (mut self Empty) content_set(i int, b string) {
}

pub fn (mut self Empty) id_set(i int) int {
	return 0
}

pub fn (mut self Empty) actionpointers(args ActionsGetArgs) []&Action {
	return []&Action{}
}

pub fn (mut self Empty) delete_last()! {
	
}

pub fn (mut self Empty) last() !&Element {
	return error("ss")
}


pub fn (mut self Empty) defpointers() []&Def {
	return []&Def{}
}

pub fn (mut self Empty) header_name() !string {
	return ''
}

pub fn (mut self Empty) actions(args ActionsGetArgs) []&playbook.Action {
	return []&playbook.Action{}
}
