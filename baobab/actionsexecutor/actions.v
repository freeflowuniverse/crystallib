module actionsexecutor

import freeflowuniverse.crystallib.baobab.actions

pub fn execute(mut actions []actions.Action) ! {
	currencies_execute(actions)!
}
