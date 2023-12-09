module elements

import freeflowuniverse.crystallib.data.paramsparser
import freeflowuniverse.crystallib.data.actionparser

interface Element {
	markdown() string
	html() string
	actions() []actionparser.Action
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

fn (mut self Doc) remove_empty_elements() ! {
	mut to_delete := []int{}
	for id, element in self.children {
		// remove the elements which are empty
		if element.content.trim_space() == '' {
			to_delete << id
		}
	}

	self.delete_from_children(to_delete)
}

fn (mut self Doc) delete_from_children(to_delete []int) {
	mut write := 0
	mut delete_ind := 0
	for i := 0; i < self.children.len; i++ {
		if delete_ind < to_delete.len && i == to_delete[delete_ind] {
			delete_ind++
			continue
		}
		self.children[write] = self.children[i]
		write++
	}

	self.children = self.children[0..write]
}

pub fn (mut self Doc) process_elements() !int {
	self.remove_empty_elements()!

	for {
		mut changes := 0
		for id, _ in self.children {
			mut element := self.children[id]
			changes += element.process(mut self)!
		}
		if changes == 0 {
			break
		}
	}
	return 0
}

pub fn (self Doc) markdown() string {
	mut out := ''
	for element in self.children {
		print('element ${element.id} markdown: ${element.markdown()}')
		out += element.markdown()
	}
	return out
}

pub fn (mut self Doc) html() string {
	mut out := ''
	for mut element in self.children {
		out += element.html()
	}
	return out
}

fn (mut self Doc) treeview_(prefix string, mut out []string) {
	out << '${prefix}- ${self.type_name:-30} ${self.content.len}'
	for mut element in self.children {
		element.treeview_(prefix + '  ', mut out)
	}
}

pub fn (mut doc Doc) html_new(args ElementNewArgs) &Html {
	mut a := Html{
		content: args.content
		type_name: 'html'
		id: doc.newid()
	}

	set_children(mut doc, &a, args.parent)

	return &a
}

fn set_children(mut doc Doc, element Element, args ?ElementRef) {
	if mut parent := args {
		parent.ref.children << element
	} else {
		doc.children << element
	}
}

@[params]
pub struct ElementNewArgs {
pub mut:
	content string
	parent  ?ElementRef
}

pub struct ElementRef {
pub mut:
	ref Element
}

pub fn (mut doc Doc) paragraph_new(args ElementNewArgs) &Paragraph {
	mut a := Paragraph{
		content: args.content
		type_name: 'paragraph'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) action_new(args ElementNewArgs) &Action {
	mut a := Action{
		content: args.content
		type_name: 'action'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) table_new(args ElementNewArgs) &Table {
	mut a := Table{
		content: args.content
		type_name: 'table'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) header_new(args ElementNewArgs) &Header {
	mut a := Header{
		content: args.content
		type_name: 'header'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) text_new(args ElementNewArgs) &Text {
	mut a := Text{
		content: args.content
		type_name: 'text'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) comment_new(args ElementNewArgs) &Comment {
	mut a := Comment{
		content: args.content
		type_name: 'comment'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) include_new(args ElementNewArgs) &Include {
	mut a := Include{
		content: args.content
		type_name: 'include'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) codeblock_new(args ElementNewArgs) &Codeblock {
	mut a := Codeblock{
		content: args.content
		type_name: 'codeblock'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}

pub fn (mut doc Doc) link_new(args ElementNewArgs) &Link {
	mut a := Link{
		content: args.content
		type_name: 'link'
		id: doc.newid()
	}
	set_children(mut doc, &a, args.parent)
	return &a
}
