module markdowndocs

import freeflowuniverse.crystallib.params

fn test_macro() {
	mut text := "Command.1.X arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok'"
	result := macro_parse(text) or { panic(err) }
	println(result)

	r := MacroObj{
		cmd: 'command.1.x'
		params: params.Params{
			params: [params.Param{
				key: 'color'
				value: 'red'
			}, params.Param{
				key: 'priority'
				value: 'incredible'
			}, params.Param{
				key: 'description'
				value: 'with spaces, lets see if ok'
			}]
			args: ['arg1', 'arg2']
		}
	}
	assert r == result
}
