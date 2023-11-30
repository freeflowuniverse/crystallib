module elements

import freeflowuniverse.crystallib.data.actionparser

@[heap]
pub struct Codeblock {
	DocBase
pub mut:
	category string
}

pub fn (mut self Codeblock) process() !int {
	if self.processed {
		return 0
	}
	mut collection := actionparser.parse_collection(text: self.content)!
	mut d := self.doc or { panic('no doc') }
	for mut action in collection.actions {
		mut a := d.action_new(parent: self.id)
		a.action = action
	}

	// now see if there is something left in codeblock, if yes add that one to the parent_elements
	if collection.othertext.len > 0 {
		d.text_new(parent: self.id, content: collection.othertext)
	}

	self.process_elements()!
	self.processed = true
	return 1
}

pub fn (self Codeblock) markdown() string {
	mut out := ''
	out += '```${self.category}\n'
	out += self.content.trim_space()
	out += '\n```\n'
	return out
}

pub fn (mut self Codeblock) html() string {
	panic('implement')
	// TODO: implement html
	return ''
}
