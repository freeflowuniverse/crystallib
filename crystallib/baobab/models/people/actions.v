module people

import freeflowuniverse.crystallib.data.actionparser { Actions }
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.paramsparser

fn (mut m MemDB) actions(actions_ Actions) ! {
	mut actions2 := actions_.filtersort(actor: 'people')!
	for action in actions2 {
		if action.name == 'person_define' {
			panic('implement person_define')
		}
	}
}
