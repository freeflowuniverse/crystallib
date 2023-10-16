module twinsafe

import freeflowuniverse.crystallib.core.actionsparser
import freeflowuniverse.crystallib.core.texttools

// this allows you to input the required info into the keysafe

fn (mut ks KeysSafe) actions(act actionsparser.Actions) ! {
	mut actions2 := act.filtersort(actor: 'twinsafe')!
	for action in actions2 {
		if action.name == 'mytwin_define' {
			mut name := action.params.get_default('name', '')!
			mut descr := action.params.get_default('descr', '')!

			// TODO: fill in the keysafe, in mem and call save...
		}
	}
}
