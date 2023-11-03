module paramsparser

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

pub fn new_from_dict(kwargs map[string]string) !Params {
	mut p := Params{}
	for key, val in kwargs {
		p.kwarg_set(key, val)
	}
	return p
}

pub fn new_params() Params {
	return Params{}
}

pub fn (mut params Params) kwarg_delete(key string) {
	key2 := key.to_lower().trim_space()
	if params.exists(key) {
		mut params_out := []Param{}
		for p in params.params {
			if p.key != key2 {
				params_out << p
			}
		}
		params.params = params_out
	}
}

pub fn (mut params Params) kwarg_set(key string, value string) {
	mut key2 := ''
	mut value2 := ''

	key2 = key.to_lower().trim_space()

	value2 = value.trim(" '")
	value2 = value2.replace('<<BR>>', '\n')
	value2 = value2.replace('\\n', '\n')
	value2 = value2.trim_right(' ')

	params.kwarg_delete(key)
	params.params << Param{
		key: key2
		value: value2
	}
}

pub fn (mut params Params) arg_delete(key string) {
	key2 := key.to_lower().trim_space()
	if params.arg_exists(key2) {
		params.args.delete(params.args.index(key2))
	}
}

pub fn (mut params Params) arg_set(value string) {
	mut value2 := value.trim(" '")
	value2 = value2.replace('<<BR>>', '\n')
	if !params.arg_exists(value2) {
		params.args << value2
	}
}

// parse new txt as params and merge into params
pub fn (mut params Params) merge(txt string) ! {
	paramsnew := parse(txt)!
	for p in paramsnew.params {
		params.kwarg_set(p.key, p.value)
	}
	for a in paramsnew.args {
		params.arg_set(a)
	}
}

pub fn (mut p Params) empty() bool {
	if p.params.len == 0 && p.args.len == 0 {
		return true
	}
	return false
}

pub fn (p Params) str() string {
	mut out := ''
	out = p.export(
		presort: ['id', 'cid', 'oid', 'name']
		indent: '    '
		maxcolsize: 120
		multiline: true
	)
	return out
}
