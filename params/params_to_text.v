module params

pub fn (mut result Params) str() string {
	mut string_array := []string{}
<<<<<<< HEAD
	string_array << 'params:'
=======
	string_array << "params:"
>>>>>>> ebb33075538a32a1773f9900c05591c4f6be37c8
	for param in result.params {
		string_array << '$param.key: "$param.value",'
	}
	string_array << 'args:'
	for arg in result.args {
		string_array << '"$arg.value",'
	}

	return string_array.join('\n')
}

/*
pub fn (mut p Params) to_resp () []u8 {

	mut param_array := resp.RArray{}
	for param in p.params {
		param_array.values << resp.RArray {
			values: [
				resp.r_string(param.key),
				resp.r_string(param.value)
			]
		}
	}

	mut arg_array := resp.RArray{}
	for arg in p.args {
		arg_array.values << resp.r_string(arg.value)
	}

	mut final_array := resp.RArray{
		values: [
			param_array,
			arg_array
		]
	}

	return resp.encode([final_array])
}

pub fn from_resp (bytes []u8) Params {
	mut params := Params{}
	mut char_array := bytes.bytestr().replace('\r\n', '').split('')

	char_array = char_array[1..char_array.len]
	for char_array.first() != '*' {
		char_array = char_array[1..char_array.len]
	}
	char_array = char_array[1..char_array.len]

	mut num_string := ''
	for i in char_array {
		if i == '*' || i == '\r' {
			break
		} else {
			num_string = num_string + i
		}
	}
	mut items_left := num_string.int()
	mut params_array := char_array.join('').split_nth('*', items_left+3)
	args_string := params_array.pop()
	params_array = params_array[1..params_array.len]
	params_array = params_array.map(it[1..it.len])
	mut args := args_string.split('+')
	args = args[1..args.len]

	for param_pair in params_array {
		param := Param{
		key : param_pair[1..param_pair.len].all_before('+')
		value : param_pair.all_after_last('+')
		}
		params.params << param
	}
	for arg in args {
		params.args << Arg{value: arg}
	}

	println(params)

	return params
}
*/
/*
RArray {
	values: [
		RArray { // params
			values: [
				RArray { //param
					values: [
						RString, // key,
						RString // value
					]
				},
				RArray { //param
					values: [
						RString, // key,
						RString // value
					]
				},
				RArray { //param
					values: [
						RString, // key,
						RString // value
					]
				}
			]
		},
		RArray { //args
			values: [
				RString, // arg
				RString, // arg
				RString // arg
			]
		}
	]
}

Params {
	params: [
		Param {
			key: string,
			value: string
		},
		Param {
			key: string,
			value: string
		},
		Param {
			key: string,
			value: string
		}
	],
	args: [
		Arg {
			value: string
		},
		Arg {
			value: string
		},
		Arg {
			value: string
		}
	]
}
*/
