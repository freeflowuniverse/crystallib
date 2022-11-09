module params

import texttools

pub struct Params {
pub mut:
	params []Param
	args   []Arg
}

pub struct Arg {
pub:
	value string
}

pub struct Param {
pub:
	key   string
	value string
}

fn new_params() Params {
	return Params{}
}

enum ParamStatus {
	start
	name // found name of the var (could be an arg)
	value_wait // wait for value to start (can be quote or end of spaces and first meaningful char)
	value // value started, so was no quote
	quote // quote found means value in between ''
}

pub fn (mut result Params) kwarg_add(key string, value string) {
	mut key2 := ''
	mut value2 := ''

	key2 = key.to_lower().trim_space()

	value2 = value.trim(" '")
	value2 = value2.replace('<<BR>>', '\n')

	result.params << Param{
		key: key2
		value: value2
	}
}

pub fn (mut result Params) arg_add(value string) {
	mut value2 := value.trim(" '")
	value2 = value2.replace('<<BR>>', '\n')

	result.args << Arg{
		value: value2
	}
}

// convert text with e.g. color:red or color:'red' to arguments
// multiline is supported
// result is params object which allows you to query the info you need
// params is following:
//
// struct Params {
// 	params []Param
// 	args   []Arg
// }
// struct Arg {
// 	value string
// }
// struct Param {
// 	key   string
// 	value string
// }
// it has nice methods to query the params
pub fn text_to_params(text string) !Params {
	mut text2 := texttools.dedent(text)
	text2 = texttools.multiline_to_single(text2)!
	text2 = text2.replace('\\n', '<<BR>>')
	text2 = text2.replace('\n', ' ')

	validchars := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_,.'

	mut ch := ''
	mut state := ParamStatus.start
	mut result := Params{}
	mut key := ''
	mut value := ''

	for i in 0 .. text2.len {
		ch = text2[i..i + 1]
		// println(" - $ch ${state}")
		// check for comments end
		if state == ParamStatus.start {
			if ch == ' ' {
				continue
			}
			state = ParamStatus.name
		}
		if state == ParamStatus.name {
			if ch == ' ' && key == '' {
				continue
			}
			// waiting for :
			if ch == ':' {
				state = ParamStatus.value_wait
				continue
			} else if ch == ' ' {
				state = ParamStatus.start
				result.arg_add(key)
				key = ''
				continue
			} else if !validchars.contains(ch) {
				return error("text to params processor: parameters can only be A-Za-z0-9 and _., here found: '$key$ch' in\n$text2\n\n")
			} else {
				key += ch
				continue
			}
		}
		if state == ParamStatus.value_wait {
			if ch == "'" {
				state = ParamStatus.quote
				continue
			}
			// means the value started, we can go to next state
			if ch != ' ' {
				state = ParamStatus.value
			}
		}
		if state == ParamStatus.value {
			if ch == ' ' {
				state = ParamStatus.start
				result.kwarg_add(key, value)
				key = ''
				value = ''
			} else {
				value += ch
			}
			continue
		}
		if state == ParamStatus.quote {
			if ch == "'" {
				state = ParamStatus.start
				result.kwarg_add(key, value)
				key = ''
				value = ''
			} else {
				value += ch
			}
			continue
		}
	}

	// last value
	if state == ParamStatus.value || state == ParamStatus.quote {
		result.kwarg_add(key, value)
	}

	if state == ParamStatus.name {
		if key != '' {
			result.arg_add(key)
		}
	}

	return result
}
