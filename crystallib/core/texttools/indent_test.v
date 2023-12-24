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
