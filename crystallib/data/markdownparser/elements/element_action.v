module elements

import freeflowuniverse.crystallib.core.playbook

@[heap]
pub struct Action {
	DocBase
pub mut:
	action playbook.Action
}

fn (mut self Action) process(mut doc Doc) !int {
	if self.processed {
		return 0
	}
	self.action = playbook.parse(text: self.content)!
	self.process_base()!
	self.process_elements(mut doc)!
	self.processed = true
	return 1
}

fn (self Action) markdown() string {
	return self.action.script3()
}

fn (self Action) html() string {
	return self.markdown()
}
