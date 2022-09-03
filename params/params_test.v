module params

import json

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

		name2:   test
		name3: hi name10:'this is with space'  name11:aaa11

		#some comment

		name4: 'aaa'

		//somecomment
		name5:   'aab' 
	"

	expectedresult := Params{
		params: [Param{
			key: 'id'
			value: 'a1'
		}, Param{
			key: 'name6'
			value: 'aaaaa'
		}, Param{
			key: 'name'
			value: 'need to do something 1'
		}, Param{
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
		}, Param{
			key: 'name2'
			value: 'test'
		}, Param{
			key: 'name3'
			value: 'hi'
		}, Param{
			key: 'name10'
			value: 'this is with space'
		}, Param{
			key: 'name11'
			value: 'aaa11'
		}, Param{
			key: 'name4'
			value: 'aaa'
		}, Param{
			key: 'name5'
			value: 'aab'
		}]
	}

	// expectedresult

	params := text_to_params(text) or { panic(err) }

	// need to replace /t because of the way how I put the expected result in code here
	assert json.encode(params) == json.encode(expectedresult).replace('\\t', '    ')
}

fn test_macro_args() {
	mut text := "arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok'"
	params := text_to_params(text) or { panic(err) }
	// println(params)

	expexted_res := Params{
		params: [Param{
			key: 'color'
			value: 'red'
		}, Param{
			key: 'priority'
			value: 'incredible'
		}, Param{
			key: 'description'
			value: 'with spaces, lets see if ok'
		}]
		args: [Arg{
			value: 'arg1'
		}, Arg{
			value: 'arg2'
		}]
	}

	assert expexted_res == params

	mut text2 := "arg1 color:red priority:'incredible' arg2    description:'with spaces, lets see if ok'"
	params2 := text_to_params(text2) or { panic(err) }

	assert expexted_res == params2
}

fn test_args_get() {
	mut text := "arg1  color:red priority:'2' description:'with spaces, lets see if ok' x:5 arg2"
	mut params := text_to_params(text) or { panic(err) }

	println(params)

	assert params.arg_exists('arg1')
	assert params.arg_exists('arg2')
	assert !params.arg_exists('arg')

	mut x := params.get_int('x') or { panic(err) }
	assert x == 5
	x = params.get_int('y') or { 6 }
	assert x == 6
	x = params.get_int('priority') or { panic(err) }
	assert x == 2

	mut y := params.get('priority') or { panic(err) }
	assert y == '2'
}
