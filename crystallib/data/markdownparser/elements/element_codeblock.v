module elements

import freeflowuniverse.crystallib.data.actionparser

pub struct CodeBlock {
	DocBase
pub mut:
	category string
}

fn (mut self CodeBlock) process() !int {
	self.parent.elements<<self
	if self.processed{		
		return 0
	}
	mut collection:=actionparser.parse_collection(text:self.content)!
	for action in collection.actions{
		self.elements<<Action{action:action}
	}
	
	//now see if there is something left in codeblock, if yess add that one to the parent_elements
	if collection.othertext.len>0{
		action_new(parent:self.parent,content:collection.othertext)!
	}

	self.process_elements()!
	self.processed=true
	parent_elements << self
	return 1
}


fn (mut self CodeBlock) markdown() string {
	mut out := ''
	out += '```${self.category}\n'
	out += self.content.trim_space()
	out += '\n```\n\n'
	return out
}

fn (mut self CodeBlock) html() string {
	return self.markdown()
}
