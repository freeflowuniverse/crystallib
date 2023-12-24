module paramsparser

fn test_to_resp() {
	text := '
		key1: {replace_me}
		key2: {Value}
		key3: value
		arg1
		arg2
	'

	mut params := new(text)!

	encoded := params.to_resp()!

	decoded_params := from_resp(encoded)!

	assert params == decoded_params
}
