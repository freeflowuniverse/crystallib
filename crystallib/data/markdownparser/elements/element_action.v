module elements

import freeflowuniverse.crystallib.data.actionparser

@[heap]
pub struct Action {
	DocBase
pub mut:
	action actionparser.Action
}

fn (mut self Action) process() !int {
	if self.processed {
		return 0
	}
	self.process_base()!
	self.process_elements()!
	self.processed = true
	return 1
}

fn (self Action) markdown() string {
	return self.action.script3()
}

fn (mut self Action) html() string {
	return self.markdown()
}
