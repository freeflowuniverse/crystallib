module paramsparser

import freeflowuniverse.crystallib.core.texttools
import json

const textin = "
	id:a1 name6:aaaaa
	name:'need to do something 1' 
	//comment
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
	params := parse(paramsparser.textin) or { panic(err) }

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
	mut params := parse(paramsparser.textin)!

	d := params.export()

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
	mut params := parse(paramsparser.textin2) or { panic(err) }

	d := params.export()

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
	mut params := parse(paramsparser.textin2) or { panic(err) }

	d := params.export()
	mut params2 := importparams(d) or { panic(err) }

	assert params.equal(params2)
}

fn test_import2() {
	mut params := parse(paramsparser.textin2) or { panic(err) }

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
	mut params2 := importparams(d)!

	assert params.equal(params2)
}

fn test_hexhash() {
	mut params := parse(paramsparser.textin2)!
	h := params.hexhash()
	assert h == 'e3517c4daa5526cf7a6f200de10a81a9db95460ecd469a53d8dca9d659228c20'
}

fn test_params_default_false() {
	mut params := parse('
	certified:false
	certified1:no
	certified2:n
	certified3:0
	')!

	assert params.get_default_false('certified') == false
	assert params.get_default_false('certified1') == false
	assert params.get_default_false('certified2') == false
	assert params.get_default_false('certified3') == false
	assert params.get_default_false('certified4') == false
}

fn test_params_default_true() {
	mut params := parse('
	certified:true
	certified1:yes
	certified2:y
	certified3:1
	')!

	assert params.get_default_true('certified') == true
	assert params.get_default_true('certified1') == true
	assert params.get_default_true('certified2') == true
	assert params.get_default_true('certified3') == true
	assert params.get_default_true('certified4') == true
}

fn test_kwargs_add() {
	mut params := parse(paramsparser.textin2) or { panic(err) }

	println(params.params)

	assert params.params.len == 10

	params.kwarg_set('name3', 'anotherhi')
	assert params.params.len == 10
	params.kwarg_set('name7', 'anotherhi')
	assert params.params.len == 11 // because is new one

	assert params.get('name3') or { '' } == 'anotherhi'
}

fn test_args_add() {
	mut params := parse('urgency:yes red green') or { panic(err) }

	println(params.args)

	assert params.params.len == 1
	assert params.args.len == 2

	params.arg_set('red')
	assert params.args.len == 2
	params.arg_set('yellow')
	assert params.args.len == 3
}

fn test_merge() {
	mut params := parse('urgency:yes red green') or { panic(err) }

	println(params.args)

	params.merge('urgency:green blue') or { panic('s') }

	println(params.args)

	assert params.params.len == 1
	assert params.args.len == 3

	assert params.get('urgency') or { '' } == 'green'
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
