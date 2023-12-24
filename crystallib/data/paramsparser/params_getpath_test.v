module paramsparser

import os

fn test_get_path() {
	os.create('/tmp/f1')!

	text := '
		key1: v1
		key2: /tmp/f1
	'

	params := new(text)!

	if _ := params.get_path('key1') {
		assert false, '"path "v1" is invalid'
	}
	assert params.get_path('key2')! == '/tmp/f1'
}

fn test_get_path_create() {
	text := '
		key1: val2
		key2: /tmp/f2
	'

	params := new(text)!

	assert params.get_path_create('key2')! == '/tmp/f2'
}
