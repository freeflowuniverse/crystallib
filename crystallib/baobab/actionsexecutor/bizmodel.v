module actionsexecutor

import freeflowuniverse.crystallib.core.actionsparser

// fn git(mut actions actionsparser.Actions, action actionsparser.Action) ! {
// 	if action.name == 'init' {
// 		// means we support initialization afterwards
// 		c.bizmodel_init(mut actions, action)!
// 	}

// 	// if action.name == 'get' {
// 	// 	mut gs := gittools.get()!
// 	// 	url := action.params.get('url')!
// 	// 	branch := action.params.get_default('branch', '')!
// 	// 	reset := action.params.get_default_false('reset')!
// 	// 	pull := action.params.get_default_false('pull')!
// 	// 	mut gr := gs.repo_get_from_url(url: url, branch: branch, pull: pull, reset: reset)!
// 	// }
// }
