module texttools
import freeflowuniverse.crystallib.ui.console

fn check_result(tocheck_ string, output string) {
	mut tocheck := tocheck_
	tocheck = tocheck.replace('\\n', '\\\\n')
	// tocheck=tocheck.replace("\'","\\'")
	tocheck = tocheck.trim_space()
	if tocheck == output.trim_space() {
		return
	}
	console.print_debug('-------\n${tocheck}')
	console.print_debug('-------\n${output.trim_space()}\n-------')
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
				console.print_debug()
			```
		'
	"
	text = multiline_to_single(text) or { panic(err) }

	required_result := 'id:a1 name:\'need to do something 1\' description:\'## markdown works in it\\n\\ndescription can be multiline\\nlets see what happens\\n\\n"yes, this needs to work too"\\n\\n- a\\n- something else\\n- "something\\n\\n### subtitle\\n\\n```python\\n#even code block in the other block, crazy parsing for sure\\ndef test():\\n    console.print_debug()\\n```\''

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

// @[assert_continues]
// fn test_comment_start_check() {
// 	// TEST: `hello // world, this is mario'`, `hello //world //this is mario`
// 	mut res := []string{}
// 	mut str := "hello // world, this is mario'"
// 	mut text, mut comment := comment_start_check(mut res, str)

// 	assert text == 'hello'
// 	assert res == ["// world, this is mario'-/"]
// 	assert comment == ''

// 	res = []string{}
// 	str = 'hello //world //this is mario'
// 	text, comment = comment_start_check(mut res, str)

// 	assert text == 'hello'
// 	assert res == ['//world //this is mario-/']
// 	assert comment == ''
// }

// @[assert_continues]
// fn test_multiline_start_check() {
// 	// TEST: `hello '''world:'''`, `hello ' world:'`, `hello " world:"`, `hello """ world: """`
// 	mut text := ["hello '''world:'''", "hello ' world:'", 'hello " world:"', 'hello """ world: """',
// 		'hello world: 		"""\n"""']
// 	expected := [false, false, false, false, true]
// 	for idx, input in text {
// 		got := multiline_start_check(input)
// 		assert got == expected[idx]
// 	}
// }

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
