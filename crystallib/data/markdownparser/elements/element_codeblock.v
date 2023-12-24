module elements

import freeflowuniverse.crystallib.core.playbook

@[heap]
pub struct Codeblock {
	DocBase
pub mut:
	category string
}

pub fn (mut self Codeblock) process(mut doc Doc) !int {
	if self.processed {
		return 0
	}
	mut playbook := playbook.parse_playbook(text: self.content)!
	for mut action in playbook.actions {
		mut a := doc.action_new(
			parent: ElementRef{
				ref: self
			}
			content: action.script3()
		)
		a.action = action
		a.processed = true
	}

	// now see if there is something left in codeblock, if yes add that one to the parent_elements
	if playbook.othertext.len > 0 {
		doc.text_new(
			parent: ElementRef{
				ref: self
			}
			content: playbook.othertext
		)
	}

	self.process_elements(mut doc)!
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
