module paramsparser

fn test_replace(){
	text := '
		key1: {replace_me}
		key2: {Value}
		key3: value
	'

	mut params := new(text)!

	mp := {
		'value': 'replaced_value'
		'replace_me': 'also_replaced_value'
	}

	params.replace(mp)

	assert params.get('key1')! == 'also_replaced_value'
	assert params.get('key2')! == 'replaced_value'
	assert params.get('key3')! == 'value'
}