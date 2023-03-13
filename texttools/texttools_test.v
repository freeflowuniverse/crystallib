module texttools

fn test_dedent() {
	mut text := '
		a
			b

			c
		d
		

	'
	text = dedent(text)
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
