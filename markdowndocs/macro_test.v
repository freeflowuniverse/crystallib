module markdowndocs

import freeflowuniverse.crystallib.params { Arg, Param }

fn test_macro() {
	mut text := "Command.1.X arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok'"
	result := macro_parse(text) or { panic(err) }
	println(result)

	r := MacroObj{
		cmd: 'command.1.x'
		params: params.Params{
			params: [Param{
				key: 'color'
				value: 'red'
			}, Param{
				key: 'priority'
				value: 'incredible'
			}, Param{
				key: 'description'
				value: 'with spaces, lets see if ok'
			}]
			args: [Arg{
				value: 'arg1'
			}, Arg{
				value: 'arg2'
			}]
		}
	}

	assert r == result
}
