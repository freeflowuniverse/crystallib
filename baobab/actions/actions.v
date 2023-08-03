module actions

import freeflowuniverse.crystallib.actionsparser

pub fn execute(mut actions []actionsparser.Action) ! {
	currencies_execute(actions)!
}
