module paramsparser

fn test_replace() {
	text := "
		key1:'{replace_me}'
		key2: {Value}
		key3: value
	"

	mut params := new(text)!

	mp := {
		'value':      'replaced_value'
		'replace_me': 'also_replaced_value'
	}

	params.replace(mp)

	assert params.get('key1')! == 'also_replaced_value'
	assert params.get('key2')! == 'replaced_value'
	assert params.get('key3')! == 'value'
}

fn test_replace2() {
	params_to_replace_txt := "
		key1:'{replace_me}'
		key2: {Value}
		key3: value
	"

	mut params_to_replace := new(params_to_replace_txt)!

	params_args_txt := '
		value:replaced_value
		replace_me:also_replaced_value
	'
	mut params_args := new(params_args_txt)!

	params_to_replace.replace_from_params(params_args)

	assert params_to_replace.get('key1')! == 'also_replaced_value'
	assert params_to_replace.get('key2')! == 'replaced_value'
	assert params_to_replace.get('key3')! == 'value'
}
