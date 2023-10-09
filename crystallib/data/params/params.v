module params

[heap]
pub struct Params {
pub mut:
	params []Param
	args   []string
}

pub struct Param {
pub mut:
	key   string
	value string
}

// get params from txt, same as parse()
pub fn new(txt string) !Params {
	return parse(txt)!
}

pub fn new_params() Params {
	return Params{}
}

pub fn (mut result Params) kwarg_add(key string, value string) {
	mut key2 := ''
	mut value2 := ''

	key2 = key.to_lower().trim_space()

	value2 = value.trim(" '")
	value2 = value2.replace('<<BR>>', '\n')
	value2 = value2.replace('\\n', '\n')
	value2 = value2.trim_right(' ')

	result.params << Param{
		key: key2
		value: value2
	}
}

pub fn (mut result Params) arg_add(value string) {
	mut value2 := value.trim(" '")
	value2 = value2.replace('<<BR>>', '\n')
	result.args << value2
}

pub fn (mut p Params) empty() bool {
	if p.params.len == 0 && p.args.len == 0 {
		return true
	}
	return false
}

pub fn (mut p Params) str() string {
	mut out := ''
	out = p.export(indent: '    ')
	out = out.trim_right('\n')
	return out
}
