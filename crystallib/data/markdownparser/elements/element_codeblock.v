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
	if pb.actions.len > 0 {
		for mut action in pb.actions {
			mut a := self.action_new(mut self.parent_doc,'')
			a.action = *action
			a.processed = true
			a.content = action.heroscript()
		}
		// now see if there is something left in codeblock, if yes add that one to the parent_elements
		if pb.othertext.len > 0 {
			self.text_new(mut self.parent_doc,pb.othertext)
		}
		self.content = '' // because is now in the children
	}

	self.process_children()!
	self.processed = true
	return 1
}

pub fn (self Codeblock) markdown() string {
	mut out := ''
	out += '```${self.category}\n'

	for action in self.actions() {
		out += action.str() + '\n'
	}
	if self.content.len > 0 {
		out += self.content.trim_space()
		out += '\n```\n'
	} else {
		out += '```\n'
	}

	return out
}

pub fn (self Codeblock) html() string {
	panic('implement')
	// TODO: implement html
	return ''
}
