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
		}
	]	
}

fn test_get_currencyamount() ! {
	// testusd
	mut amount := testparams.get_currencyamount('dollars')!
	assert amount.currency.name == 'USD'
	assert amount.currency.usdval == 1.0
	assert amount.val == 100.0

	// testeuro
	amount = testparams.get_currencyamount('euros')!
	assert amount.currency.name == 'EUR'
	assert amount.currency.usdval > 1 // may need revision in future
	assert amount.val == 100.0
}

fn test_get_currencyamount_default() ! {
	// testeuro
	mut amount := testparams.get_currencyamount_default('na', '20EUR')!
	assert amount.currency.name == 'EUR'
	assert amount.currency.usdval > 1 // may need revision in future
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