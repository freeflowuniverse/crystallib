module actionsexecutor

import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.baobab.context


fn (mut c context.Context) git(mut actions actions.Actions, action action.Action) ! {

	if action.name == 'get' {
		mut gs:=c.gitstructure()!
		mut url := action.params.get('url')!
		mut branch := action.params.get_default('branch', '')!
		mut reset := action.params.get_default_false('reset')!
		mut pull := action.params.get_default_false('pull')!
		mut gr := gs.repo_get_from_url(url: url, branch: branch, pull: pull, reset: reset)!
	}
	
}
