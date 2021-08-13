module texttools

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

pub fn new_params() Params {
	return Params{}
}

enum ParamStatus {
	start
	name // found name of the var (could be an arg)
	value_wait // wait for value to start (can be quote or end of spaces and first meaningful char)
	value // value started, so was no quote
	quote // quote found means value in between ''
}

// return string, will be trimmed
// get kwarg return as string, ifn't exist return the defval
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (mut tp Params) get(key_ string) ?string {
	key := key_.to_lower()
	for p in tp.params {
		if p.key == key {
			return p.value.trim(' ')
		}
	}
	return error('Did not find key:$key in $tp')
}

// get kwarg return as string, ifn't exist return the defval
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (mut tp Params) get_default(key string, defval string) ?string {
	if tp.exists(key) {
		valuestr := tp.get(key) ?
		return valuestr.trim(' ')
	}
	return defval
}

// get kwarg return as int
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (mut tp Params) get_int(key string) ?int {
	valuestr := tp.get(key) ?
	return valuestr.int()
}

// get kwarg return as int, if it doesnt' exist return a default
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (mut tp Params) get_int_default(key string, defval int) ?int {
	if tp.exists(key) {
		valuestr := tp.get(key) ?
		return valuestr.int()
	}
	return defval
}

// get kwarg, and return list of string
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (mut tp Params) get_list(key string) ?[]string {
	mut res := []string{}
	if tp.exists(key) {
		mut valuestr := tp.get(key) ?
		if valuestr.contains(',') {
			valuestr = valuestr.trim(' ,')
			res = valuestr.split(',').map(it.trim(' \'"'))
		} else {
			res = [valuestr.trim(' \'"')]
		}
	}
	return res
}

// get kwarg, and return list of ints
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (mut tp Params) get_list_int(key string) ?[]int {
	mut res := []int{}
	if tp.exists(key) {
		mut valuestr := tp.get(key) ?
		if valuestr.contains(',') {
			valuestr = valuestr.trim(' ,')
			res = valuestr.split(',').map(it.trim(' \'"').int())
		} else {
			res = [valuestr.trim(' \'"').int()]
		}
	}
	return res
}

// check if kwarg exist
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg

pub fn (mut tp Params) exists(key_ string) bool {
	key := key_.to_lower()
	for p in tp.params {
		if p.key == key {
			return true
		}
	}
	return false
}

// check if arg exist (arg is just a value in the string e.g. red, not value:something)
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (mut tp Params) arg_exists(key_ string) bool {
	key := key_.to_lower()
	for p in tp.args {
		if p.value == key {
			return true
		}
	}
	return false
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
pub fn text_to_params(text string) ?Params {
	mut text2 := dedent(text)
	text2 = multiline_to_single(text2) ?
	text2 = text2.replace('\\n', '<<BR>>')
	text2 = text2.replace('\n', ' ')

	validchars := 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_,'

	mut char := ''
	mut state := ParamStatus.start
	mut result := Params{}
	mut key := ''
	mut value := ''

	for i in 0 .. text2.len {
		char = text2[i..i + 1]
		// println(" - $char ${state}")
		// check for comments end
		if state == ParamStatus.start {
			if char == ' ' {
				continue
			}
			state = ParamStatus.name
		}
		if state == ParamStatus.name {
			if char == ' ' && key == '' {
				continue
			}
			// waiting for :
			if char == ':' {
				state = ParamStatus.value_wait
				continue
			} else if char == ' ' {
				state = ParamStatus.start
				result.arg_add(key)
				key = ''
				continue
			} else if !validchars.contains(char) {
				return error("parameters can only be A-Za-z0-9 and _, here found: '$key$char' in\n$text2")
			} else {
				key += char
				continue
			}
		}
		if state == ParamStatus.value_wait {
			if char == "'" {
				state = ParamStatus.quote
				continue
			}
			// means the value started, we can go to next state
			if char != ' ' {
				state = ParamStatus.value
			}
		}
		if state == ParamStatus.value {
			if char == ' ' {
				state = ParamStatus.start
				result.kwarg_add(key, value)
				key = ''
				value = ''
			} else {
				value += char
			}
			continue
		}
		if state == ParamStatus.quote {
			if char == "'" {
				state = ParamStatus.start
				result.kwarg_add(key, value)
				key = ''
				value = ''
			} else {
				value += char
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
