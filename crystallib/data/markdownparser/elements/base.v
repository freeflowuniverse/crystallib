module elements

import freeflowuniverse.crystallib.core.pathlib
// import freeflowuniverse.crystallib.core.smartid
import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.core.playbook

@[heap]
pub struct DocBase {
pub mut:
	id        int
	content   string
	path      ?pathlib.Path
	processed bool
	// params    paramsparser.Params
	type_name string
	changed   bool
	children  []Element
	parent ?&Element @[skip; str: skip]
	trailing_lf bool = true //do we need to do a line feed (enter) at end of this element, default yes
}

fn (mut self DocBase) process_base() ! {	
}

fn (mut self DocBase) remove_empty_children()  {	
	self.children = self.children.filter(!(it.content.trim_space() == '' && it.children.len==0 ))
}

pub fn (mut self DocBase) process() !int {	
	if self.processed {
		return 0
	}
	self.remove_empty_children()
	self.process_base()!
	self.process_children()!
	self.content = "" //because now the content is in children	
	self.processed = true
	return 1
}

@[params]
pub struct ActionsGetArgs {
pub mut:
	actor     string
	name   string
}

//get all actions from the children
pub fn (self DocBase) actions(args ActionsGetArgs) []playbook.Action {
	mut out := []playbook.Action{}
	for element in self.children {
		if element is Action {
			mut found:=true
			if args.actor.len>0 && args.actor!=element.action.actor{found=false}
			if args.name.len>0 && args.name!=element.action.name{found=false}
			if found{
				out << element.action
			}			
		}else{
			out << element.actions(args)
		}
	}
	return out
}

pub fn (mut self DocBase) action_pointers(args ActionsGetArgs) []ActionPointer {
	mut out := []ActionPointer{}
	for mut element in self.children {
		if mut element is Action {
			mut found:=true
			if args.actor.len>0 && args.actor!=element.action.actor{found=false}
			if args.name.len>0 && args.name!=element.action.name{found=false}
			if found{
				out << ActionPointer{action:element.action,doc_element:&element}
			}			
		}
		out << element.action_pointers(args)
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

pub fn (mut self DocBase) process_children() !int {
	mut changes := 0
	for mut element in self.children {
		changes += element.process()!
	}
	return changes
}

fn (self DocBase) treeview_(prefix string, mut out []string) {
	mut c:=self.content
	c=c.replace("\n","\\n").replace("  "," ")
	if c.len>80{
		c=c[0..80]
	}
	out << '${prefix}- ${self.type_name:-30} ${c.len}  $c'
	for mut element in self.children() {
		element.treeview_(prefix + ' ', mut out)
	}
}

pub fn (self DocBase) html() string {
	mut out := ''
	for mut element in self.children() {
		out += element.html()
	}
	return out
}

pub fn (self DocBase) markdown() string {
	mut out := ''
	for mut element in self.children() {
		out += element.markdown()
		if element.trailing_lf{
			out+="\n"
		}
	}
	return out
}

pub fn (self DocBase) last() !Element {
	if self.children.len == 0 {
		return error('doc has no children')
	}
	mut l:=self.children.last()
	return l
}

pub fn (mut self DocBase) delete_last() ! {
	if self.children.len == 0 {
		return error('doc has no children')
	}

	self.children.delete_last()
}
