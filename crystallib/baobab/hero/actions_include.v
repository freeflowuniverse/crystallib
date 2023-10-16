module hero

import freeflowuniverse.crystallib.data.actionsparser
import freeflowuniverse.crystallib.osal.downloader

// recursive include of actions
fn (mut s Session) actions_include(myactions []actionsparser.Action) ![]actionsparser.Action {
	mut actionsprocessed := []actionsparser.Action{}
	mut includefound := false
	// lets first resolve the includes and process after including
	for action in myactions {
		if action.actor == 'runner' && action.name == 'include' {
			includefound = true
			mut sourceurl := action.params.get_default('source', '')!
			if sourceurl.len < 5 {
				return error('Cannot include: ${sourceurl}, is <5 chars. \n${s}')
			}
			s.includes << sourceurl

			m := downloader.download(url: sourceurl, reset: false)!

			ap_include := actions.new(path: m.path)!
			mut actions_include := ap_include.filtersort(actor: 'runner')!
			for action_include in actions_include {
				actionsprocessed << action_include
			}
		} else {
			actionsprocessed << action
		}
	}
	if includefound {
		actionsprocessed = s.actions_include(actionsprocessed)!
	}
	return actionsprocessed
}
