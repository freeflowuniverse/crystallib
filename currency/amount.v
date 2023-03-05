module currency

pub struct Amount {
pub mut:
	currency &Currency
	val      f64
	currencies Currencies [str: skip]
}

// convert an Amount into usd
// ARGS:
// - Amount
// TODO: hard code in exchange rates, later this struct can be filled in with an API or something
pub fn (a Amount) usd() f64 {
	// calculate usd value towards f64
	usd_val := a.val * a.currency.usdval
	return f64(usd_val)
}

// amount_get
// gets amount and currency from a string input
// ARGS:
// - amount_str string : a human-written string
// -decimals are done with US notation (.)
// - check in string for format  e.g. 10.3usd or '10 usd' or '10 USD' or '10 usDC'
// allows £,$,€ to be used as special cases
pub fn (mut cs Currencies) amount_get(amount_ string) !Amount {
	mut amount := amount_.to_upper()
	numbers := ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']
	for i in ['_', ',', ' '] {
		amount = amount.replace(i, '')
	}

	amount = amount.replace('$', 'USD')
	amount = amount.replace('£', 'GBP')
	amount = amount.replace('€', 'EUR')

	// checks if amount or code given first
	mut num_first := false
	item := amount[0..1]
	if item in numbers {
		num_first = true
	}

	// split up string into two parts, code and amount
	mut code := ''
	mut num := ''
	mut split_string := amount.split('')
	if num_first {
		mut count := 0
		for index in split_string {
			if index !in numbers {
				num = amount[0..count]
				code = amount[count..amount.len]
				break
			}
			count += 1
		}
	} else {
		mut count := 0
		for index in split_string {
			if index in numbers {
				code = amount[0..count]
				num = amount[count..amount.len]
				break
			}
			count += 1
		}
	}
	// remove spaces from code and capitalise
	code=code.to_upper().trim_space()
	if !(code in cs.currencies){
		cs.get_rates([code],false)! //not sure this will work
		cs.get_rates([code],true)!
	}

	cur0:=cs.currencies[code] or {
		return error("Cannot find currency with code $code")
	}

	mut amount2 := Amount{
		val: f64(num.int())
		currency: &cur0
		currencies: &cs
	}

	return amount2
}

// pub fn (mut a0 Amount) add (a2 Amount)! {
// 	target_currency := amounts[0].currency

// 	mut total_val := f64(0)
// 	for amount in amounts {
// 		if amount.currency != target_currency {
// 			return error("Input amounts are of different currencies")
// 		}
// 		total_val += amount.val
// 	}
// 	return Amount{
// 		currency: target_currency
// 		val: total_val
// 	}
// }
