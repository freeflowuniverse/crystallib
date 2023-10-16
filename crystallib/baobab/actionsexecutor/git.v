module actionsexecutor

import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.osal.gittools

fn git(mut actions actions.Actions, action action.Action) ! {
	if action.name == 'get' {
		name := action.params.get('name')!
		gitname := action.params.get_default('gitname', 'default')!
		mut gs := gittools.get()!
		url := action.params.get('url')!
		branch := action.params.get_default('branch', '')!
		reset := action.params.get_default_false('reset')!
		pull := action.params.get_default_false('pull')!
		mut gr := gs.repo_get_from_url(url: url, branch: branch, pull: pull, reset: reset)!
	}
}
