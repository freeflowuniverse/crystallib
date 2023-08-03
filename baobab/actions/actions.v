module actions

import freeflowuniverse.crystallib.baobab.actionsparser

pub fn execute(mut actions []actionsparser.Action) ! {
	currencies_execute(actions)!
}
