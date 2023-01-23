module params

import texttools
import os

// check if kwarg exist
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (mut params Params) exists(key_ string) bool {
	key := key_.to_lower()
	for p in params.params {
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
pub fn (mut params Params) arg_exists(key_ string) bool {
	key := key_.to_lower()
	for p in params.args {
		if p == key {
			return true
		}
	}
	return false
}

// see if the kwarg with the key exists
// if yes return as string trimmed
pub fn (mut params Params) get(key_ string) !string {
	key := texttools.name_fix(key_)
	for p in params.params {
		if p.key == key {
			return p.value.trim(' ')
		}
	}
	return error('Did not find key:${key} in ${params}')
}

// get kwarg return as string, ifn't exist return the defval
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (mut params Params) get_default(key string, defval string) !string {
	if params.exists(key) {
		valuestr := params.get(key)!
		return valuestr.trim(' ')
	}
	return defval
}

// get kwarg return as int
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (mut params Params) get_int(key string) !int {
	valuestr := params.get(key)!
	return valuestr.int()
}

pub fn (mut params Params) get_u32(key string) !u32 {
	valuestr := params.get(key)!
	return valuestr.u32()
}

pub fn (mut params Params) get_u8(key string) !u8 {
	valuestr := params.get(key)!
	return valuestr.u8()
}



// get kwarg return as int, if it doesnt' exist return a default
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (mut params Params) get_int_default(key string, defval int) !int {
	if params.exists(key) {
		valuestr := params.get(key)!
		return valuestr.int()
	}
	return defval
}

// get kwarg, and return list of string
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (mut params Params) get_list(key string) ![]string {
	mut res := []string{}
	if params.exists(key) {
		mut valuestr := params.get(key)!
		if valuestr.contains(',') {
			valuestr = valuestr.trim(' ,')
			res = valuestr.split(',').map(it.trim(' \'"'))
		} else {
			res = [valuestr.trim(' \'"')]
		}
	}
	return res
}

pub fn (mut params Params) get_list_namefix(key string) ![]string {
	mut res:= params.get_list(key)!
	res = res.map(texttools.name_fix(it))
	return res
}


// get kwarg, and return list of ints
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (mut params Params) get_list_int(key string) ![]int {
	mut res := []int{}
	if params.exists(key) {
		mut valuestr := params.get(key)!
		if valuestr.contains(',') {
			valuestr = valuestr.trim(' ,')
			res = valuestr.split(',').map(it.trim(' \'"').int())
		} else {
			res = [valuestr.trim(' \'"').int()]
		}
	}
	return res
}

pub fn (mut params Params) get_default_true(key string) bool {
	mut r := params.get(key) or { '' }
	r = texttools.name_fix_no_underscore(r)
	if r == '' || r == '1' || r == 'true' || r == 'y' {
		return true
	}
	return false
}

pub fn (mut params Params) get_default_false(key string) bool {
	mut r := params.get(key) or { '' }
	r = texttools.name_fix_no_underscore(r)
	if r == '' || r == '0' || r == 'false' || r == 'n' {
		return false
	}
	return true
}

// will get path and check it exists
pub fn (mut params Params) get_path(key string) !string {
	path := params.get(key)!

	if !os.exists(path) {
		return error('Cannot find path: ${key}')
	}

	return path
}

// will get path and check it exists if not will create
pub fn (mut params Params) get_path_create(key string) !string {
	path := params.get(key)!

	if !os.exists(path) {
		os.mkdir_all(path)!
	}

	return path
}
