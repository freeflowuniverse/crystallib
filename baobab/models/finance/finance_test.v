module finance

pub fn test_amount_get() {
	// assert amount_get("U s d 900").val == 900
	// assert amount_get("U s d 900").currency.name == 'USD'
	println(amount_get('U s d 900'))
	println(amount_get('euro321'))
}
