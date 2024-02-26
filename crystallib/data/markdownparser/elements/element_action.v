module elements

import freeflowuniverse.crystallib.core.playbook

@[heap]
pub struct Action {
	DocBase
pub mut:
	action playbook.Action
	action_processed bool
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
	self.process_children()!
	self.processed = true
	return 1
}

fn (self Action) markdown() string {
	if self.action_processed{
		return self.content
	}
	return self.action.heroscript()
}

fn (self Action) html() string {
	return self.markdown()
}
