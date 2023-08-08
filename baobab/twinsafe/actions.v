module bizmodel

import freeflowuniverse.crystallib.baobab.actions
import freeflowuniverse.crystallib.texttools

//this allows you to input the required info into the keysafe

fn (mut ks KeysSafe) actions(actions actions.ActionsParser) ! {
	mut actions2 := actions.filtersort(actor: 'twinsafe')!
	for action in actions2 {
		if action.name == 'mytwin_define' {
			mut name := action.params.get_default('name', '')!
			mut descr := action.params.get_default('descr', '')!

			//TODO: fill in the keysafe, in mem and call save...

		}
	}
}
