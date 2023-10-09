module blockchain

import freeflowuniverse.crystallib.baobab.actions { Actions }
import freeflowuniverse.crystallib.texttools
import freeflowuniverse.crystallib.params


fn (mut c Controller) actions(actions_ Actions) ! {
	mut actions2 := actions_.filtersort(actor: '???')!
	for action in actions2 {
		if action.name == '???' {

		}
	}