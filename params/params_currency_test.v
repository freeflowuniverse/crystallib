module params

import freeflowuniverse.crystallib.currency

const testparams = Params{
	params: [
		Param{
			key: 'dollars'
			value: '100USD'
		},
		Param{
			key: 'euros'
			value: '100EUR'
		},
	]
}

fn test_get_currencyamount() ! {
	// testusd
	mut cs := currency.new()
	mut amount := params.testparams.get_currencyamount(mut cs, 'dollars')!
	assert amount.currency.name == 'USD'
	assert amount.currency.usdval == 1.0
	assert amount.val == 100.0

	// testeuro
	amount = params.testparams.get_currencyamount(mut cs, 'euros')!
	assert amount.currency.name == 'EUR'
	assert amount.currency.usdval >= 0.9 // may need revision in future
	assert amount.val == 100.0
}

fn test_get_currencyamount_default() ! {
	// testeuro
	mut cs := currency.new()
	mut amount := params.testparams.get_currencyamount_default(mut cs, 'na', '20EUR')!
	assert amount.currency.name == 'EUR'
	assert amount.currency.usdval >= 0.9 // may need revision in future
	assert amount.val == 20
}

fn test_get_currency_float() ! {
	// todo
	// testeuro
	// mut amount := testparams.get_currencyamount_default('na', '20EUR')!
	// assert amount.currency.name == 'EUR'
	// assert amount.currency.usdval > 1 // may need revision in future
	// assert amount.val == 20
}
