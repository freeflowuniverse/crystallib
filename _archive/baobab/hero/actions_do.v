module hero

import freeflowuniverse.crystallib.develop.gittools
import freeflowuniverse.crystallib.baobab.actionsexecutor

// walk over all actions of the session & execute them
pub fn (mut s Session) actions_do() ! {
	actionsexecutor.play(
		actions: s.actions
	)!

	for action in s.actions {
		if action.actor == 'gittools' {
			gittools.action(action)!
		}
	}
}
