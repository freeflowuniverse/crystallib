module actions

import freeflowuniverse.crystallib.currency
import freeflowuniverse.crystallib.actionsparser

fn currencies_execute(actions []actionsparser.Action) ! {
	mut actions2 := actionsparser.filtersort(actions: actions, actor: 'currency', book: '*')! // URGENT: means we do for any book
	if actions2.len == 0 {
		return
	}

	mut cs := currency.new()!

	for action in actions2 {
		// URGENT: set the currencies
		if action.name == 'default_set' {
			cur := action.params.get('cur')!
			usdval := action.params.get_int('usdval')!
			cs.default_set(cur, usdval)!
		}
	}

	// URGENT: add the currency metainfo, do a test
}
