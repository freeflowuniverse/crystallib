module elements

import freeflowuniverse.crystallib.data.actionparser

pub struct Action {
	DocBase
pub mut:
	action actionparser.Action
}

fn (mut self Action) process() !int {
	if self.processed {
		return 0
	}
	self.processed = true
	return 1
}

fn (self Action) markdown() string {
	return self.action.script3()
}

fn (mut self Action) html() string {
	return self.markdown()
}

@[params]
pub struct ActionNewArgs {
	ElementNewArgs
pub mut:
	action actionparser.Action
}

pub fn action_new(args ActionNewArgs) Action {
	mut a := Action{
		content: args.content
		parents: args.parents
		action: args.action
		type_name: 'action'
		action:actionparser.parse(text: args.content)!
	}
	if args.add2parent {
		for mut parent in a.parents {
			parent.elements << a
		}
	}
	return a
}
