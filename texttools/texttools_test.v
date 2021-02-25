module texttools

import json

fn test_dedent() {
	mut text := '
		a
			b

			c
		d
		

	'
	text = dedent(text)
	// println("'$text'")
	assert text.len == 20
}

fn test_multiline_to_single() {
	mut text := "
		id:a1
		name:'need to do something 1'
		description:
			## markdown works in it

			description can be multiline
			lets see what happens

			- a
			- something else

			### subtitle

			```python
			#even code block in the other block, crazy parsing for sure
			def test():
				print()
			```
	"
	text = multiline_to_single(text) or { panic(err) }

	mut required_result := "
	id:a1
	name:'need to do something 1'
	description:'## markdown works in it\\n\\ndescription can be multiline\\nlets see what happens\\n\\n- a\\n- something else\\n\\n### subtitle\\n\\n```python\\n#even code block in the other block, crazy parsing for sure\\ndef test():\\n    print()\\n```'
	"
	assert dedent(required_result).trim_space() == dedent(text).trim_space()
}

fn test_multiline_to_params() {
	mut text := "
		id:a1 name6:aaaaa
		name:'need to do something 1' 
		description:
			## markdown works in it

			description can be multiline
			lets see what happens

			- a
			- something else

			### subtitle

			```python
			#even code block in the other block, crazy parsing for sure
			def test():
				print()
			```

		name2 :   test
		name3: hi name10 :'this is with space'  name11:aaa11

		#some comment

		name4 : 'aaa'

		//somecomment
		name5 :   'aab' 
	"

	expectedresult := TextParams{
		params: [TextParam{
			key: 'id'
			value: 'a1'
		}, TextParam{
			key: 'name6'
			value: 'aaaaa'
		}, TextParam{
			key: 'name'
			value: 'need to do something 1'
		}, TextParam{
			key: 'description'
			value: '## markdown works in it

description can be multiline
lets see what happens

- a
- something else

### subtitle

```python
#even code block in the other block, crazy parsing for sure
def test():
	print()
```
'
		}, TextParam{
			key: 'name2'
			value: 'test'
		}, TextParam{
			key: 'name3'
			value: 'hi'
		}, TextParam{
			key: 'name10'
			value: 'this is with space'
		}, TextParam{
			key: 'name11'
			value: 'aaa11'
		}, TextParam{
			key: 'name4'
			value: 'aaa'
		}, TextParam{
			key: 'name5'
			value: 'aab'
		}]
	}

	// expectedresult

	params := text_to_params(text) or { panic(err) }

	// need to replace /t because of the way how I put the expected result in code here
	assert json.encode(params) == json.encode(expectedresult).replace('\\t', '    ')
}

fn test_text_args() {
	mut r := []string{}
	r = text_to_args("'aa bb'   ' cc dd' one -two") or { panic(err) }
	assert r == ['aa bb', 'cc dd', 'one', '-two']
	r = text_to_args("'\taa bb'   ' cc dd' one -two") or { panic(err) }
	assert r == ['\taa bb', 'cc dd', 'one', '-two']
	// now spaces
	r = text_to_args("  '\taa bb'    ' cc dd'  one -two ") or { panic(err) }
	assert r == ['\taa bb', 'cc dd', 'one', '-two']
	// now other quote
	r = text_to_args('"aa bb"   " cc dd" one -two') or { panic(err) }
	assert r == ['aa bb', 'cc dd', 'one', '-two']
	r = text_to_args('"aa bb"   \' cc dd\' one -two') or { panic(err) }
	assert r == ['aa bb', 'cc dd', 'one', '-two']

	r = text_to_args('find . /tmp') or { panic(err) }
	assert r == ['find', '.', '/tmp']

	r = text_to_args("bash -c 'find /'") or { panic(err) }
	assert r == ['bash', '-c', 'find /']

	mut r2 := string{}
	r2 = text_remove_quotes('echo "hi >" > /tmp/a.txt')
	assert r2 == 'echo  > /tmp/a.txt'
	r2 = text_remove_quotes("echo 'hi >' > /tmp/a.txt")
	assert r2 == 'echo  > /tmp/a.txt'
	r2 = text_remove_quotes("echo 'hi >' /tmp/a.txt")
	assert r2 == 'echo  /tmp/a.txt'
	assert check_exists_outside_quotes("echo 'hi >' > /tmp/a.txt", ['<', '>', '|'])
	assert check_exists_outside_quotes("echo 'hi ' /tmp/a.txt |", ['<', '>', '|'])
	assert !check_exists_outside_quotes("echo 'hi >'  /tmp/a.txt", ['<', '>', '|'])

	r = text_to_args('echo "hi" > /tmp/a.txt') or { panic(err) }
	assert r == ['echo', '"hi" > /tmp/a.txt']
}

// fn test_text_args(){

// 	mut args := []string{}
// 	text := "
// 	$test something $test2T 
// 	a$TEST
// 		b${TEST}c
// 	"
// 	args = template_find_args(text)
// 	println(args)
// 	panic("A")
// }
