module paramsparser

fn test_get_arg() {
	text := '
		key1: val1
		key2: val2

		arg1
		arg2
	'

	params := new(text)!
	assert params.get_arg(0)! == 'arg1'
	assert params.get_arg(1)! == 'arg2'
	arg3 := params.get_arg(2) or { 'arg3 does not exists' }
	assert arg3 == 'arg3 does not exists'
}

fn test_get_arg_check() {
	text := '
		key1: val1
		key2: val2

		arg1
		arg2
	'

	params := new(text)!

	assert params.get_arg_check(0, 2)! == 'arg1'
	assert params.get_arg_check(1, 2)! == 'arg2'
	t3 := params.get_arg_check(1, 3) or { 'len is 2' }
	assert t3 == 'len is 2'
	t4 := params.get_arg_check(2, 2) or { 'len is 2' }
	assert t4 == 'len is 2'
}

fn test_check_arg_len() {
	text := '
		key1: val1
		key2: val2

		arg1
		arg2
	'

	params := new(text)!

	if _ := params.check_arg_len(0) {
		assert false, 'arg len should be 2'
	}
	if _ := params.check_arg_len(1) {
		assert false, 'arg len should be 2'
	}
	params.check_arg_len(2) or { assert false }
	if _ := params.check_arg_len(3) {
		assert false, 'arg len should be 2'
	}
}

fn test_get_arg_default() {
	text := '
		key1: val1
		key2: val2

		arg1
		arg2
	'

	params := new(text)!

	assert params.get_arg_default(0, 'arg3')! == 'arg1'
	assert params.get_arg_default(1, 'arg3')! == 'arg2'
	assert params.get_arg_default(2, 'arg3')! == 'arg3'
	assert params.get_arg_default(3, 'arg3')! == 'arg3'
}

fn test_get_arg_int() {
	text := '
		key1: val1
		key2: val2

		arg1
		arg2
		13
	'

	params := new(text)!

	if _ := params.get_arg_int(0) {
		assert false, 'first argument is a string, not an int'
	}
	if _ := params.get_arg_int(1) {
		assert false, 'second argument is a string, not an int'
	}
	assert params.get_arg_int(2)! == 13
	if _ := params.get_arg_int(3) {
		assert false, 'there is no 4th argument'
	}
}

fn test_get_arg_int_default() {
	text := '
		key1: val1
		key2: val2

		arg1
		arg2
		13
	'

	params := new(text)!

	if _ := params.get_arg_int_default(0, 5) {
		assert false, '1st argument is a string, not an int'
	}
	if _ := params.get_arg_int_default(1, 5) {
		assert false, '2nd argument is a string, not an int'
	}
	assert params.get_arg_int_default(2, 5)! == 13
	assert params.get_arg_int_default(3, 5)! == 5
}
