module elements

import freeflowuniverse.crystallib.core.playbook

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
	mut pb := playbook.new(text: self.content)!
	for mut action in pb.actions {
		mut a := self.action_new(action.script3())
		a.action = *action
		a.processed = true
	}

	// now see if there is something left in codeblock, if yes add that one to the parent_elements
	if pb.othertext.len > 0 {
		self.text_new(pb.othertext)
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

pub fn (self Codeblock) html() string {
	panic('implement')
	// TODO: implement html
	return ''
}
