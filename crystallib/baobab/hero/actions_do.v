module hero

import freeflowuniverse.crystallib.osal.gittools
// import freeflowuniverse.crystallib.baobab.actors.publisher

// walk over all actions of the session & execute them
pub fn (mut s Session) actions_do() ! {
	// publisher.play(
	// 	actions: s.actions
	// )!

	for action in s.actions {
		if action.actor == 'gittools' {
			gittools.action(action)!
		}
	}
}
