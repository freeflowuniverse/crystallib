module blockchain

import freeflowuniverse.crystallib.core.actionsparser { Actions }
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.paramsparser

// TODO: not implemented,

fn (mut c Controller) actions(actions_ Actions) ! {
	mut actions2 := actions_.filtersort(actor: '???')!
	for action in actions2 {
		if action.name == '???' {
		}
	}
}
