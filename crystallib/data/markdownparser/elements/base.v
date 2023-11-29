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
	path      pathlib.Path
	processed bool
	params    paramsparser.Params
	type_name string
	changed   bool
	children  []Element
}

fn (mut self DocBase) process_base() ! {
	for mut element in self.children() {
		// remove the elements which are empty
		if element.content.trim_space() == '' {
			self.children.delete(element.id)
		}
	}
}

pub fn (self DocBase) actions() []actionparser.Action {
	mut out := []actionparser.Action{}
	for element in self.children() {
		match element {
			Action {
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

pub fn (self DocBase) children() []Element {
	return self.children
}

pub fn (mut self DocBase) process_elements(mut doc Doc) !int {
	for {
		mut changes := 0
		for mut element in self.children {
			changes += element.process(mut doc)!
		}
		if changes == 0 {
			break
		}
	}
	return 0
}

fn (self DocBase) treeview_(prefix string, mut out []string) {
	out << '${prefix}- ${self.type_name:-30} ${self.content.len}'
	for mut element in self.children() {
		element.treeview_(prefix + ' ', mut out)
	}
}

pub fn (mut self DocBase) html() string {
	mut out := ''
	for mut element in self.children() {
		out += element.html()
	}
	return out
}

pub fn (mut self DocBase) markdown() string {
	mut out := ''
	for mut element in self.children() {
		out += element.markdown()
	}
	return out
}
