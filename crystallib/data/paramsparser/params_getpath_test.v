module paramsparser

import os

fn test_get_path() {
	os.open_file('/tmp/f1', 'wr', 0, 6, 4, 4)!

	text := '
		key1: val1
		key2: /tmp/f1
	'

	params := new(text)!

	params.get_path('key1') or { assert true }
	assert params.get_path('key2')! == '/tmp/f1'
}

fn test_get_path_create() {
	text := '
		key1: val1
		key2: /tmp/f2
	'

	params := new(text)!

	params.get_path_create('key1') or { assert true }
	assert params.get_path_create('key2')! == '/tmp/f2'
}
