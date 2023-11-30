module elements

import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.data.actionparser

@[heap]
pub struct DocBase {
pub mut:
	id        int
	content   string
	doc       ?&Doc               @[skip; str: skip]
	path      pathlib.Path
	processed bool
	params    paramsparser.Params
	type_name string
	changed   bool
	parent    int
	children  []int
}

fn (mut self DocBase) process_base() ! {
	for mut element in self.children() {
		// remove the elements which are empty
		if element.content.trim_space() == '' {
			self.children.delete(element.id)
		}
	}
}

@[params]
pub struct ElementNewArgs {
pub mut:
	content string
	parent  int
}

pub fn (self DocBase) actions() []actionparser.Action {
	mut out := []actionparser.Action{}
	for element in self.children() {
		// println(element.type_name)
		match element {
			Action {
				println(1)
				out << element.action
				out << element.actions()
			}
			else {}
		}
	}
	return out
}

pub fn (self DocBase) treeview() string {
	mut out := []string{}
	self.treeview_('', mut out)
	return out.join_lines()
}

pub fn (self DocBase) children() []&DocElement {
	mut d := self.doc or { panic('no doc') }
	mut res := []&DocElement{}
	for id in self.children {
		mut e := d.elements[id] or { panic('cant find doc with id: ${id}') }
		res << e
	}
	return res
}

pub fn (self DocBase) parent() &DocElement {
	mut d := self.doc or { panic('no doc') }
	return d.elements[self.parent] or { panic('cant find doc with id: ${self.parent}') }
}

// pub fn (self DocBase) markdown() !string {
// 	mut out:=[]string{}
// 	for _, element in self.children(){
// 		out<<element.markdown()!
// 	}
// 	return out.join_lines()
// }

// pub fn (self DocBase) html()! string {
// 	mut out:=[]string{}
// 	for _, element in self.children(){
// 		out<<element.html()!
// 	}
// 	return out.join_lines()
// }
