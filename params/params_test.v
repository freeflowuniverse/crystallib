module params

import freeflowuniverse.crystallib.texttools
import json

const textin = "
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

const textin2 = "
	zz
	id:a1 name6:aaaaa
	name:'need to do something 1' 
	description:'something\\nyes'

	aa
	bb
	name2:   test
	name3: hi name10:'this is with space'  name11:aaa11

	#some comment

	name4: 'aaa'

	//somecomment
	name5:   'aab' 
"

fn test_multiline_to_params() {
	params := parse(params.textin) or { panic(err) }

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

	// need to replace /t because of the way how I put the expected result in code here
	assert json.encode(params) == json.encode(expectedresult).replace('\\t', '    ')
}

fn test_macro_args() {
	mut text := "arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok'"
	params := parse(text) or { panic(err) }

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
		args: ['arg1', 'arg2']
	}

	assert expexted_res == params

	mut text2 := "arg1 color:red priority:'incredible' arg2    description:'with spaces, lets see if ok'"
	params2 := parse(text2) or { panic(err) }

	assert expexted_res == params2
}

fn test_args_get() {
	mut text := "arg1  color:red priority:'2' description:'with spaces, lets see if ok' x:5 arg2"
	mut params := parse(text) or { panic(err) }

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

// fn test_json() {

// 	mut params := parse(textin) or { panic(err) }

// 	d:=params.json_export()

// 	mut params2 := json_import(d) or {panic(err)}

// 	panic("ssss")

// }

fn test_export() {
	mut params := parse(params.textin) or { panic(err) }

	d := params.export() or { panic(err) }

	mut out := "
	description:'## markdown works in it\\n\\ndescription can be multiline\\nlets see what happens\\n\\n- a\\n- something else\\n\\n### subtitle\\n\\n```python\\n#even code block in the other block, crazy parsing for sure\\ndef test():\\n    print()\\n```'
	id:a1
	name:'need to do something 1'
	name10:'this is with space'
	name11:aaa11
	name2:test
	name3:hi
	name4:aaa
	name5:aab
	name6:aaaaa
	"
	assert texttools.dedent(d) == texttools.dedent(out).trim_space()
}

fn test_export2() {
	mut params := parse(params.textin2) or { panic(err) }

	d := params.export() or { panic(err) }

	mut out := "
	description:something\\nyes
	id:a1
	name:'need to do something 1'
	name10:'this is with space'
	name11:aaa11
	name2:test
	name3:hi
	name4:aaa
	name5:aab
	name6:aaaaa
	aa
	bb
	zz	
	"
	assert texttools.dedent(d) == texttools.dedent(out).trim_space()
}

fn test_import1() {
	mut params := parse(params.textin2) or { panic(err) }

	d := params.export() or { panic(err) }
	mut params2 := importparams(d) or { panic(err) }

	assert params.equal(params2)!
}

fn test_import2() {
	mut params := parse(params.textin2) or { panic(err) }

	d := "
	id:a1
	zz
	name:'need to do something 1'
	name10:'this is with space'
	name11:aaa11
	name2:test
	name3:hi
	name4:aaa
	name5:aab
	name6:aaaaa
	aa
	bb
	description:something\\nyes

	"
	mut params2 := importparams(d) or { panic(err) }

	assert params.equal(params2)!
}

fn test_hexhash() {
	mut params := parse(params.textin2) or { panic(err) }
	h := params.hexhash() or { panic(err) }
	assert h == 'e3517c4daa5526cf7a6f200de10a81a9db95460ecd469a53d8dca9d659228c20'
}

/*
fn test_to_resp_from_resp() {
	mut input := Params{
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
		args: [Arg{
			value: '111'
		}, Arg{
			value: '222'
		}, Arg{
			value: '333'
		}]
	}

	mut bytes := input.to_resp()!

	mut p := from_resp(bytes)?

	// expected result shown below
}
*/
/*
expected_result := "
		id: 'a1'
		name6: 'aaaaa'
		name: 'need to do something 1'
		description: '## markdown works in it

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
		name2: 'test'
		name3: 'hi'
		name10: 'this is with space'
		name11: 'aaa11'
		name4: 'aaa'
		name5: 'aab'
		args:
		'111'
		'222'
		'333'
	"
*/
