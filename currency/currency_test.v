module currency

// pub fn test_amount_get() {
// 	// assert amount_get("U s d 900").val == 900
// 	// assert amount_get("U s d 900").currency.name == 'USD'
// 	println(amount_get('U s d 900'))
// 	println(amount_get('euro321'))
// 	panic("SSD"
// 	)
// }

pub fn test_singleton_get() {
	mut cs := new()!
	assert cs.currencies.len > 0
	// mut cs2 := new()!
	
}

pub fn test_rates_get() {
	mut cs := new()!
	cs.get_rates(['EUR', 'AED', 'USD', 'EGP'], false)!
	// last arg is to say its a crypto
	cs.get_rates(['TERRA', 'TFT', 'XLM', 'USDC'], true)!

	cs.currencies['TFT'] = &Currency{
		name: 'TFT'
		usdval: 0.01
	}
	cs.currencies['AED'] = &Currency{
		name: 'AED'
		usdval: 0.25
	}

	mut u := cs.amount_get('1$')!
	u2 := u.exchange(cs.currency_get('tft')!)!
	assert u2.val == 100.0

	mut a := cs.amount_get('10Aed')!
	mut b := cs.amount_get('AED 10')!
	assert a.val == b.val
	assert a.currency == b.currency
	assert a.val == 10.0

	c := a.exchange(cs.currency_get('tft ')!)!
	assert c.val == 250.0

	mut aa2 := cs.amount_get('0')!
	assert aa2.val == 0.0

	mut aa := cs.amount_get('10')!
	assert aa.val == 10.0
	assert aa.currency.usdval == 0.0
	assert aa.currency.name == ''
}
