module elements

import freeflowuniverse.crystallib.data.actionparser

pub struct Action {
	DocBase	
pub mut:
	action actionparser.Action
}

fn (mut self Action) process() !int {
	self.parent.elements<<self
	if self.processed{		
		return 0
	}
	self.processed = true
	return 1
}

fn (mut self Action) markdown() string {
	return self.action.script3()
}

fn (mut self Action) html() string {
	return self.markdown()
}

[params]
pub struct ActionNewArgs{
	ElementNewArgs
pub mut:
	action actionparser.Action
}

fn action_new(args ActionNewArgs) !Action {
	mut a:=Action{
		content: args.content
		parent: args.parent
		action: args.action
	}
	if args.add2parent{
		args.parent.elements << a
	}
	return a
}
