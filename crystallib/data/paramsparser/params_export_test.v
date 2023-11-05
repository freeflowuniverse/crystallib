module paramsparser

import crypto.sha256

const textin5 = "
	red green blue purpose somethingmore
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

fn test_export_helper1() {
	params := parse(paramsparser.textin5) or { panic(err) }

	// presort []string
	// args_allowed bool=true
	// maxcolsize int = 80
	// oneline bool //if set then will put all on oneline
	// multiline bool = true //if we will put the multiline strings as multiline in output
	// indent string
	o := params.export_helper(maxcolsize: 600) or { panic(err) }
	assert o[o.len - 1].firstline == false
	assert o[o.len - 2].firstline == true
	assert o[o.len - 1].key == 'description'
	assert o[o.len - 2].key == 'name6'
}

fn test_export_helper2() {
	params := parse(paramsparser.textin5) or { panic(err) }

	// presort []string
	// args_allowed bool=true
	// maxcolsize int = 80
	// oneline bool //if set then will put all on oneline
	// multiline bool = true //if we will put the multiline strings as multiline in output
	// indent string
	o := params.export_helper(
		presort: ['id', 'gid', 'cid', 'oid', 'name']
		indent: '    '
		maxcolsize: 120
		multiline: true
	) or { panic(err) }
	println('2')
	println(params)
	hh := sha256.hexhash(o.str())
	assert hh == '4bdf0c219fd146f6f1e4634013b97e16d3cc9888ca86149f5352b6edcfd5242b'
	// println(hh)

	// println(params)
}

fn test_export_helper3() {
	params := parse(paramsparser.textin5) or { panic(err) }

	// presort []string
	// args_allowed bool=true
	// maxcolsize int = 80
	// oneline bool //if set then will put all on oneline
	// multiline bool = true //if we will put the multiline strings as multiline in output
	// indent string
	o := params.export(
		presort: ['id', 'cid', 'oid', 'name']
		args_remove: true
		maxcolsize: 120
		multiline: true
	)
	o2 := params.export_helper(
		presort: ['id', 'cid', 'oid', 'name']
		args_remove: true
		maxcolsize: 120
		multiline: true
	)!
	println('3')
	println(o)

	hh := sha256.hexhash(o)
	assert hh == 'c76b65708aefbc86ac60199c57d5106bad76ed77a569eacc292caa6571cbb3ca'
}

fn test_export_helper4() {
	params := parse(paramsparser.textin5) or { panic(err) }

	// presort []string
	// args_allowed bool=true
	// maxcolsize int = 80
	// oneline bool //if set then will put all on oneline
	// multiline bool = true //if we will put the multiline strings as multiline in output
	// indent string
	o := params.export(
		presort: ['id', 'cid', 'oid', 'name']
		args_remove: true
		maxcolsize: 120
		multiline: true
		oneline: true
	)
	println(o)
	println('4')
	hh := sha256.hexhash(o)
	assert hh == '0863331010844ece9ac6e754cc285677011ede1a1d0cbabdb6a1a24bd8f6b75c'
	println(hh)

	println(params)

	// if true{
	// 	panic('s')
	// }
}
