module paramsparser

fn test_params_exists() {
	test := '
		key1: val1
		key2: val2
		key3: val3
		arg1
	'
	params := new(test)!
	assert params.exists('key1') == true
	assert params.exists('KeY1') == true
	assert params.exists('key2') == true
	assert params.exists('key3') == true
	assert params.exists('key4') == false
	assert params.exists('arg1') == false

	assert params.exists_arg('arg1') == true
	assert params.exists_arg('ArG1') == true
	assert params.exists_arg('key1') == false
}
