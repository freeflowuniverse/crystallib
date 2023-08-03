module actions

import freeflowuniverse.crystallib.currency
import freeflowuniverse.crystallib.actionsparser

fn currencies_execute(actions []actionsparser.Action) ! {
	mut actions2 := actionsparser.filtersort(actions: actions, actor: 'currency', book: '*')!
	if actions2.len == 0 {
		return
	}

	mut cs := currency.new()!

	for action in actions2 {
		// TODO: set the currencies
		if action.name == 'default_set' {
			cur := action.params.get('cur')!
			usdval := action.params.get_int('usdval')!
			cs.default_set(cur, usdval)!
		}
	}

	// TODO: add the currency metainfo, do a test
}
