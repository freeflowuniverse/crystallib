module paramsparser

import crypto.sha256

const textin5 = "
	//this is first comment (line1)
	//this is 2nd comment (line2)
	red green blue
	id:a1 name6:aaaaa //comment_line2
	name:'need to do something 1' 
	//comment
	description:'
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
	'
	name2:   test
	name3: hi name10:'this is with space'  name11:aaa11

	name4: 'aaa'

	//somecomment
	name5:   'aab' 
"

// fn test_export_helper1() {
// 	params := parse(paramsparser.textin5) or { panic(err) }

// 	// presort []string
// 	// args_allowed bool=true
// 	// maxcolsize int = 80
// 	// oneline bool //if set then will put all on oneline
// 	// multiline bool = true //if we will put the multiline strings as multiline in output
// 	// indent string
// 	o := params.export_helper(maxcolsize: 600) or { panic(err) }
// 	println(o)
// 	assert o.len == 14
// 	// println(o.len)
// 	assert o[o.len - 1].firstline == false
// 	// println(o[o.len - 2])
// 	assert o[o.len - 2].firstline == true
// 	assert o[o.len - 1].key == 'description'
// 	assert o[o.len - 2].key == 'name6'
// 	assert o[0].comment.len>0
// 	assert o[0].key==""
// 	assert o[0].value==""
// 	assert sha256.hexhash(o.str()) == "204a4f286a793c202e4f63e2dbb15b77b1f8e2781d812f57750b51eaaca718d9"

// }

// fn test_export_helper2() {
// 	params := parse(paramsparser.textin5) or { panic(err) }
// 	o := params.export_helper(maxcolsize: 60) or { panic(err) }
// 	println(o)
// 	assert sha256.hexhash(o.str()) == "c8ef61a194897c1b4132e2956cfb934fa912e3845a39a33cea05c76197479836"

// }


const textin6 = "
	//mycomment
	red blue
	id:a1 name6:aaaaa 

	name4: 'a aa' //comment_line2

	//somecomment
	name5:   'aab' 
"
fn test_export_6() {
	params := parse(paramsparser.textin6) or { panic(err) }
	o := params.export_helper(maxcolsize: 60) or { panic(err) }
	println(o)

	paramsout := params.export()

	println(paramsout)

	assert sha256.hexhash(paramsout) == "e03d099d5cc2b9b086b903fb34dce25cc34251be5624b984bb6ea90e2394b18e"

}


const textin7 = "
	//mycomment
	red blue
	id:a7 name6:aaaaa 

	name4: '
		multiline1
			in

		multiline2
		'

	//somecomment
	name5:   'aab' 
"
fn test_export_7() {
	params := parse(paramsparser.textin7) or { panic(err) }
	o := params.export_helper(maxcolsize: 60) or { panic(err) }
	println(o)

	paramsout := params.export()

	println(paramsout)

	assert sha256.hexhash(paramsout) == "6c737d031d5d7c9fbaa23044546123f200e4dfa12daaf054c7864dcd6f28a9f5"

}


const textin8 = "
	//mycomment
	red blue
	id:a8 name6:aaaaa 

	name4: '
		multiline1
			in

		multiline2
		'

	//somecomment
	//
	//multiline
	name5:   'aab' 
"
fn test_export_8() {
	params := parse(paramsparser.textin8) or { panic(err) }
	o := params.export_helper(maxcolsize: 60) or { panic(err) }
	println(o)

	paramsout := params.export()

	println(paramsout)

	assert sha256.hexhash(paramsout) == "7a0bd845c2f8f9616ef914bb1be8d8618dd0c08df8d743a43d9b35cc35eac101"

}

const textin9 = "
	//mycomment
	red blue
	id:a9 name6:aaaaa 

	name4: '
		multiline1
			in

		multiline2
		'

	//somecomment
	//
	//multiline
	name5:   'aab' 
"
fn test_export_9() {
	params := parse(paramsparser.textin9) or { panic(err) }
	o := params.export_helper(oneline:true) or { panic(err) }
	println(o)

	paramsout := params.export(oneline:true)

	println(paramsout)

	assert sha256.hexhash(paramsout) == "811bef1e55b3b4b1b725e1a7514b092526c8fdef8dddf6ad15f9d1ca49c3eb51"

}


const textin10 = "
	//mycomment
	red blue
	id:a9 name6:aaaaa 

	name4: '
		multiline1
			in

		multiline2
		'

	//somecomment
	//
	//multiline
	name5:   'aab' 
"
fn test_export_10() {
	params := parse(paramsparser.textin10) or { panic(err) }
	o := params.export_helper(oneline:false,pre:'!!remark.define') or { panic(err) }
	println(o)

	paramsout := params.export(oneline:false,pre:'!!remark.define')

	println(paramsout)

	//WE EXPECT
	
	// // mycomment
	// !!remark.define blue red id:a9 name6:aaaaa
	//     name4:'
	//         multiline1
	//             in

	//         multiline2
	//         '
	//     // somecomment
	//     //
	//     // multiline
	//     name5:aab	

	assert sha256.hexhash(paramsout) == "a88ffafb1bceaa3c24c3b5a8fa3020b16afd5df369603ecfb77266b6fa09ed7e"

}
