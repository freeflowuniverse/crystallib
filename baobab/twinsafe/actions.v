module bizmodel

import freeflowuniverse.crystallib.baobab.actionsparser
import freeflowuniverse.crystallib.texttools

//this allows you to input the required info into the keysafe

fn (mut ks KeysSafe) actions(actions actionsparser.ActionsParser) ! {
	mut actions2 := actions.filtersort(actor: 'twinsafe')!
	for action in actions2 {
		if action.name == 'mytwin_define' {
			mut name := action.params.get_default('name', '')!
			mut descr := action.params.get_default('descr', '')!

			//TODO: fill in the keysafe, in mem and call save...

		}
	}
}
