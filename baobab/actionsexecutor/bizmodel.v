module actionsexecutor

import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.baobab.context

fn git(mut c context.Context, mut actions actions.Actions, action action.Action) ! {
	if action.name == 'init' {
		// means we support initialization afterwards
		c.bizmodel_init(mut actions, action)!
	}

	if action.name == 'get' {
		mut gs := c.gitstructure()!
		url := action.params.get('url')!
		branch := action.params.get_default('branch', '')!
		reset := action.params.get_default_false('reset')!
		pull := action.params.get_default_false('pull')!
		mut gr := gs.repo_get_from_url(url: url, branch: branch, pull: pull, reset: reset)!
	}
}
