module main

import freeflowuniverse.crystallib.params {Params, Param, Arg}
import freeflowuniverse.crystallib.resp

fn main () {

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
		}],
		args: [Arg{
			value: '111'
		}, Arg {
			value: '222'
		}, Arg {
			value: '333'
		}
		]
	}

	mut bytes := input.to_resp()!
	// println(bytes)

	mut p := params.from_resp(bytes)?
	println(p.str())
	// expected result shown below
}


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