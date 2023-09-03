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
<<<<<<< HEAD
	cs := currency.new()
	mut amount := params.testparams.get_currencyamount(cs, 'dollars')!
=======
	mut cs:=currency.new()
	mut amount := params.testparams.get_currencyamount(mut cs, 'dollars')!
>>>>>>> 57eac1e95244f94a883f8f4a5ed1e8c37e76c2cf
	assert amount.currency.name == 'USD'
	assert amount.currency.usdval == 1.0
	assert amount.val == 100.0

	// testeuro
<<<<<<< HEAD
	amount = params.testparams.get_currencyamount(cs, 'euros')!
=======
	amount = params.testparams.get_currencyamount(mut cs, 'euros')!
>>>>>>> 57eac1e95244f94a883f8f4a5ed1e8c37e76c2cf
	assert amount.currency.name == 'EUR'
	assert amount.currency.usdval >= 0.9 // may need revision in future
	assert amount.val == 100.0
}

fn test_get_currencyamount_default() ! {
	// testeuro
<<<<<<< HEAD
	mut amount := params.testparams.get_currencyamount_default(cs, 'na', '20EUR')!
=======
	mut cs:=currency.new()
	mut amount := params.testparams.get_currencyamount_default(mut cs,'na', '20EUR')!
>>>>>>> 57eac1e95244f94a883f8f4a5ed1e8c37e76c2cf
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
