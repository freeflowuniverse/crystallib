module markdowndocs

import freeflowuniverse.crystallib.data.paramsparser

fn test_macro() {
	mut text := "Command.1.X arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok'"
	result := macro_parse(text)!

	r := MacroObj{
		cmd: 'command.1.x'
		params: paramsparser.Params{
			params: [params.Param, {
				key:   'color'
				value: 'red'
			}, params.Param, {
				key:   'priority'
				value: 'incredible'
			}, params.Param, {
				key:   'description'
				value: 'with spaces, lets see if ok'
			}]
			args: ['arg1', 'arg2']
		}
	}
	assert r == result
}
