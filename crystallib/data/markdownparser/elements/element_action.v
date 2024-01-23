module elements

import freeflowuniverse.crystallib.core.playbook

@[heap]
pub struct Action {
	DocBase
pub mut:
	action playbook.Action
}

fn (mut self Action) process() !int {
	if self.processed {
		return 0
	}

	p := playbook.new(text: self.content)!
	if p.actions.len != 1 {
		return error('a single action is expected, but found ${p.actions.len}')
	}

	self.action = p.actions[0]
	self.process_base()!
	self.process_elements()!
	self.processed = true
	return 1
}

fn (self Action) markdown() string {
	return self.action.script3()
}

fn (self Action) html() string {
	return self.markdown()
}
