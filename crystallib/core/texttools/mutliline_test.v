module texttools

fn check_result(tocheck_ string, output string) {
	mut tocheck := tocheck_
	tocheck = tocheck.replace('\\n', '\\\\n')
	// tocheck=tocheck.replace("\'","\\'")
	tocheck = tocheck.trim_space()
	if tocheck == output.trim_space() {
		return
	}
	println('-------\n${tocheck}')
	println('-------\n${output.trim_space()}\n-------')
	panic('required result not correct.')
}

fn test_multiline1() {
	mut text := "
		id:a1
		name:'need to do something 1'
		description:'
			## markdown works in it

			description can be multiline
			lets see what happens

			'yes, this needs to work too'

			- a
			- something else
			- 'something

			### subtitle

			```python
			#even code block in the other block, crazy parsing for sure
			def test():
				print()
			```
		'
	"
	text = multiline_to_single(text) or { panic(err) }

	required_result := 'id:a1 name:\'need to do something 1\' description:\'## markdown works in it\\n\\ndescription can be multiline\\nlets see what happens\\n\\n"yes, this needs to work too"\\n\\n- a\\n- something else\\n- "something\\n\\n### subtitle\\n\\n```python\\n#even code block in the other block, crazy parsing for sure\\ndef test():\\n    print()\\n```\''

	check_result(required_result, text)
}

fn test_multiline2() {
	mut text := '
		id:a1
		name:\'need to do something 1\'
		description:"
			## markdown works in it

			description can be multiline
			lets see what happens
		\'
	'
	text = multiline_to_single(text) or { panic(err) }

	required_result := "id:a1 name:'need to do something 1' description:'## markdown works in it\\n\\ndescription can be multiline\\nlets see what happens'"

	check_result(required_result, text)
}

fn test_multiline3() {
	mut text := '
		id:a1
		name:\'need to do something 1\'
		description: """
			## markdown works in it

			description can be multiline
			lets see what happens
		\'
	'
	text = multiline_to_single(text) or { panic(err) }

	required_result := "id:a1 name:'need to do something 1' description:'## markdown works in it\\n\\ndescription can be multiline\\nlets see what happens'"

	check_result(required_result, text)
}

fn test_multiline4() {
	mut text := '
		id:a1
		name:\'need to do something 1\'
		description: """
			## markdown works in it

			description can be multiline
			lets see what happens
		"""
	'
	text = multiline_to_single(text) or { panic(err) }

	required_result := "id:a1 name:'need to do something 1' description:'## markdown works in it\\n\\ndescription can be multiline\\nlets see what happens'"

	check_result(required_result, text)
}

fn test_multiline5() {
	mut text := "
		id:a1 //comment1
		// a comment
		name:'need to do something 1'
		description:  '
				## markdown works in it

				description can be multiline
				lets see what happens
		'
		//another comment
	"
	text = multiline_to_single(text) or { panic(err) }

	required_result := "//comment1-/ id:a1 //a comment-/ name:'need to do something 1' description:'## markdown works in it\\n\\ndescription can be multiline\\nlets see what happens' //another comment-/"

	check_result(required_result, text)
}

fn test_multiline6() {
	mut text := "
		id:a1 //comment1

		// comment m 1
		// comment m 2
		//
		// comment m 3
		//

		name:'need to do something 1'
		description:  '
				## markdown works in it

				description can be multiline
				lets see what happens
		'
		<!--another comment-->
	"
	text = multiline_to_single(text) or { panic(err) }

	required_result := "//comment1-/ id:a1 //comment m 1\\ncomment m 2\\n\\ncomment m 3\\n-/ name:'need to do something 1' description:'## markdown works in it\\n\\ndescription can be multiline\\nlets see what happens' //another comment-/"

	check_result(required_result, text)
}

// TODO: not supported yet, requires a Comment Struct, which knows its <!-- format
// fn test_multiline7() {
// 	mut text := "
// 		id:a1 //comment1

// 		<!-- comment m 1
// 		comment m 2

// 		comment m 3
// 		-->

// 		name:'need to do something 1'
// 		description:  '
// 				## markdown works in it

// 				description can be multiline
// 				lets see what happens
// 		'
// 		<!--another comment-->
// 	"
// 	text = multiline_to_single(text) or { panic(err) }

// 	required_result:="//comment1-/ id:a1 //comment m 1\\ncomment m 2\\n\\ncomment m 3\\n-/ name:'need to do something 1' description:'## markdown works in it\\n\\ndescription can be multiline\\nlets see what happens' //another comment-/"

// 	check_result(required_result,text)

// }
