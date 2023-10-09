module system

fn test_smartid() {
	r := smartid_int('abcd')
	assert r == 481261
	assert smartid_string(r) == 'abcd'

	// panic("s")
}
