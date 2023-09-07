module gittools

import freeflowuniverse.crystallib.baobab.actions { Actions }

// get url's
// !!git.git_get .
// PARAMETERS .
// ========== .
// ```
// url    string .
// branch string .
// pull   bool // will pull if this is set .
// reset bool //this means will pull and reset all changes 
// ```
fn (mut gs GitStructure) action(actions_ []Action) ! {
	mut actions2 := actions_.filtersort(actor: 'git')!
	for action in actions2 {
		if action.name == 'git_get' {
			mut url := action.params.get('url')!
			mut branch := action.params.get_default('branch', '')!
			mut reset:=action.params.get_default_false('reset')!
			mut pull:=action.params.get_default_false('pull')!
			mut gr := gs.repo_get_from_url(url: url, branch:branch, pull: pull, reset: reset)!

		}
	}

}
