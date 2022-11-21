module texttools

// how to process command lines
fn test_cmdline_args() {
	mut r := []string{}
	r = cmd_line_args_parser("'aa bb'   ' cc dd' one -two") or { panic(err) }
	assert r == ['aa bb', 'cc dd', 'one', '-two']
	r = cmd_line_args_parser("'\taa bb'   ' cc dd' one -two") or { panic(err) }
	assert r == ['\taa bb', 'cc dd', 'one', '-two']
	// now spaces
	r = cmd_line_args_parser("  '\taa bb'    ' cc dd'  one -two ") or { panic(err) }
	assert r == ['\taa bb', 'cc dd', 'one', '-two']
	// now other quote
	r = cmd_line_args_parser('"aa bb"   " cc dd" one -two') or { panic(err) }
	assert r == ['aa bb', 'cc dd', 'one', '-two']
	r = cmd_line_args_parser('"aa bb"   \' cc dd\' one -two') or { panic(err) }
	assert r == ['aa bb', 'cc dd', 'one', '-two']

	r = cmd_line_args_parser('find . /tmp') or { panic(err) }
	assert r == ['find', '.', '/tmp']

	r = cmd_line_args_parser("bash -c 'find /'") or { panic(err) }
	assert r == ['bash', '-c', 'find /']

	mut r2 := string('')
	r2 = text_remove_quotes('echo "hi >" > /tmp/a.txt')
	assert r2 == 'echo  > /tmp/a.txt'
	r2 = text_remove_quotes("echo 'hi >' > /tmp/a.txt")
	assert r2 == 'echo  > /tmp/a.txt'
	r2 = text_remove_quotes("echo 'hi >' /tmp/a.txt")
	assert r2 == 'echo  /tmp/a.txt'
	assert check_exists_outside_quotes("echo 'hi >' > /tmp/a.txt", ['<', '>', '|'])
	assert check_exists_outside_quotes("echo 'hi ' /tmp/a.txt |", ['<', '>', '|'])
	assert !check_exists_outside_quotes("echo 'hi >'  /tmp/a.txt", ['<', '>', '|'])

	r = cmd_line_args_parser('echo "hi" > /tmp/a.txt') or { panic(err) }
	assert r == ['echo', '"hi" > /tmp/a.txt']
}
