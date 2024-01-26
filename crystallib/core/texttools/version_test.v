module texttools

fn test_version() {
	assert version(' v0. 0.36 ') == 36
	assert version(' v0.36 ') == 36
	assert version(' 36 ') == 36
	assert version(' v0. 4.36 ') == 4036
	assert version(' v2. 4.36 ') == 2004036
	assert version(' 0.18.0 ') == 18000

	assert version(' 
	
		v2. 4.36 
		') == 2004036
}
