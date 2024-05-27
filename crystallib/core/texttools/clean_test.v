module texttools
import freeflowuniverse.crystallib.ui.console

fn test_clean1() {
	mut text := "
	'''js

	'''
	something
		yes

	else

	```js

	```

	'''js

	inside
	'''


	"

	mut result := "
	something
		yes

	else

	'''js

	inside
	'''
	"

	text = dedent(text)
	result = dedent(result)

	text2 := remove_double_lines(remove_empty_js_blocks(text))

	console.print_debug('---')
	console.print_debug(text2)
	console.print_debug('---')
	console.print_debug(result)
	console.print_debug('---')

	assert text2.trim_space() == result.trim_space()
}
