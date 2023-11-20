module paramsparser

fn test_get() {
	text := '
		key1: val1
		arg1
	'

	params := new(text)!

	assert params.get('key1')! == 'val1'
	if _ := params.get('key2') {
		assert false
	} else {
		assert true
	}
	if _ := params.get('arg1') {
		assert false
	} else {
		assert true
	}
}

fn test_get_default() {
	text := '
		key1: val1
		arg1
	'

	params := new(text)!

	assert params.get_default('key1', 'def')! == 'val1'
	assert params.get_default('key2', 'def')! == 'def'
	assert params.get_default('arg1', 'def')! == 'def'
}

fn test_get_int() {
	text := '
		key1: val1
		key2: 19
		arg1
	'

	params := new(text)!

	if _ := params.get_int('key1') {
		assert false
	} else {
		assert true
	}
	assert params.get_int('key2')! == 19
	if _ := params.get_int('arg1') {
		assert false
	} else {
		assert true
	}
}

fn test_get_int_default() {
	text := '
		key1: val1
		key2: 19
		arg1
	'

	params := new(text)!

	if _ := params.get_int_default('key1', 10) {
		assert false
	} else {
		assert true
	}
	assert params.get_int_default('key2', 10)! == 19
	assert params.get_int_default('arg1', 10)! == 10
}

fn test_get_float() {
	text := '
		key1: val1
		key2: 19
		key3: 1.9
		arg1
	'

	params := new(text)!

	if _ := params.get_float('key1') {
		assert false
	} else {
		assert true
	}
	assert params.get_float('key2')! == 19
	assert params.get_float('key3')! == 1.9
	if _ := params.get_float('arg1') {
		assert false
	} else {
		assert true
	}
}

fn test_get_float_default() {
	text := '
		key1: val1
		key2: 19
		key3: 1.9
		arg1
	'

	params := new(text)!

	if _ := params.get_float_default('key1', 1.23) {
		assert false
	} else {
		assert true
	}
	assert params.get_float_default('key2', 1.23)! == 19
	assert params.get_float_default('key3', 1.23)! == 1.9
	assert params.get_float_default('arg1', 1.23)! == 1.23
}

fn test_get_percentage() {
	text := '
		key1: val1
		key2: 19
		key3: %1.9
		key4: %500
	'

	params := new(text)!

	if _ := params.get_percentage('key1') {
		assert false
	} else {
		assert true
	}
	assert params.get_percentage('key2')! == 0.19
	assert params.get_percentage('key3')! == .019
	if _ := params.get_percentage('key4') {
		assert false
	} else {
		assert true
	}
}

fn test_get_percentage_default() {
	text := '
		key1: val1
		key2: 19
		key3: %1.9
		key4: %500
	'

	params := new(text)!

	if _ := params.get_percentage_default('key1', '.17') {
		assert false
	} else {
		assert true
	}
	assert params.get_percentage_default('key2', '.17')! == 0.19
	assert params.get_percentage_default('key3', '.17')! == .019
	if _ := params.get_percentage_default('key4', '.17') {
		assert false
	} else {
		assert true
	}
	assert params.get_percentage_default('key5', '17')! == 0.17
}

fn test_get_u64() {
	text := '
		key1: val1
		key2: 19
	'

	params := new(text)!

	if _ := params.get_u64('key1') {
		assert false
	} else {
		assert true
	}
	assert params.get_u64('key2')! == 19
	if _ := params.get_u64('key3') {
		assert false
	} else {
		assert true
	}
}

fn test_get_u64_default() {
	text := '
		key1: val1
		key2: 19
	'

	params := new(text)!

	if _ := params.get_u64_default('key1', 17) {
		assert false
	} else {
		assert true
	}
	assert params.get_u64_default('key2', 17)! == 19
	assert params.get_u64_default('key3', 17)! == 17
}

fn test_get_u32() {
	text := '
		key1: val1
		key2: 19
	'

	params := new(text)!

	if _ := params.get_u32('key1') {
		assert false
	} else {
		assert true
	}
	assert params.get_u32('key2')! == 19
	if _ := params.get_u32('key3') {
		assert false
	} else {
		assert true
	}
}

fn test_get_u32_default() {
	text := '
		key1: val1
		key2: 19
	'

	params := new(text)!

	if _ := params.get_u32_default('key1', 17) {
		assert false
	} else {
		assert true
	}
	assert params.get_u32_default('key2', 17)! == 19
	assert params.get_u32_default('key3', 17)! == 17
}

fn test_get_u8() {
	text := '
		key1: val1
		key2: 19
	'

	params := new(text)!

	if _ := params.get_u8('key1') {
		assert false
	} else {
		assert true
	}
	assert params.get_u8('key2')! == 19
	if _ := params.get_u8('key3') {
		assert false
	} else {
		assert true
	}
}

fn test_get_u8_default() {
	text := '
		key1: val1
		key2: 19
	'

	params := new(text)!

	if _ := params.get_u8_default('key1', 17) {
		assert false
	} else {
		assert true
	}
	assert params.get_u8_default('key2', 17)! == 19
	assert params.get_u8_default('key3', 17)! == 17
}

fn test_get_default_true() {
	text := '
		key1: val1
		key2: true
		key3: 1
		key4: 2
		key5: y
		key6: yes
	'

	params := new(text)!

	assert params.get_default_true('key1') == false
	assert params.get_default_true('key2') == true
	assert params.get_default_true('key3') == true
	assert params.get_default_true('key4') == false
	assert params.get_default_true('key5') == true
	assert params.get_default_true('key6') == true
	assert params.get_default_true('key7') == true
}

fn test_get_default_false() {
	text := '
		key1: val1
		key2: false
		key3: 0
		key4: 1
		key5: n
		key6: no
	'

	params := new(text)!

	assert params.get_default_false('key1') == true
	assert params.get_default_false('key2') == false
	assert params.get_default_false('key3') == false
	assert params.get_default_false('key4') == true
	assert params.get_default_false('key5') == false
	assert params.get_default_false('key6') == false
	assert params.get_default_false('key7') == false
}

fn test_get_from_hashmap() {
	text := '
		key1: val1
		key2: 19
	'

	params := new(text)!

	mp := {
		'key1,19, val1': 'val2'
	}

	assert params.get_from_hashmap('key1', 'def', mp)! == 'val2'
	assert params.get_from_hashmap('key2', 'def', mp)! == 'val2'
	assert params.get_from_hashmap('key3', 'key1', mp)! == 'val2'
}

fn test_matchhashmap() {
	mp := {
		'key1,key2,key3': 'val1'
	}

	assert matchhashmap(mp, 'key1') == 'val1'
	assert matchhashmap(mp, 'key2') == 'val1'
	assert matchhashmap(mp, 'key3') == 'val1'
	assert matchhashmap(mp, 'key4') == ''
}
