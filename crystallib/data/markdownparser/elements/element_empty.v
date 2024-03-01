module elements
import freeflowuniverse.crystallib.core.playbook

//NOT USED FOR NOW

@[heap]
pub struct Empty {
pub mut:
	id        int
	content   string
	processed bool
	type_name   string
	changed     bool
	// trailing_lf bool
	children    []Element
}

pub fn (mut self Empty) process() !int {
	return 0
}

pub fn (self Empty) markdown() !string {
	return ""
}

pub fn (self Empty) pug() !string {
	return ""
}


pub fn (self Empty) html() !string {
	return ""	
}

pub fn (self Empty) treeview_(prefix string, mut out []string) {
}


pub fn (self Empty) children_recursive()[]Element {
	return []Element{}	
}

pub fn (self Empty) children_recursive_(mut e []Element){
}

pub fn (self Empty) content_set(i int, b string){
}

pub fn (self Empty) id_set(i int) int{
	return 0
}

pub fn (self Empty) actionpointers(args ActionsGetArgs)[]&Action {
	return []&Action{}	
}

pub fn (self Empty) defpointers()[]&Def {
	return []&Def{}	
}

pub fn (self Empty) header_name()!string{
	return ""
}


pub fn (self Empty) actions(args ActionsGetArgs) []playbook.Action {
	return []playbook.Action{}	
}