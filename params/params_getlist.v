module params

import texttools
import strconv

// Looks for a list of strings in the parameters. If it doesn't exist this function will return an error. Furthermore an error will be returned if the list is not properly formatted
// Examples of valid lists:
//	["example", "another_example", "yes"]
// 	['example', 'another_example']
//	['example "yes yes"', "another_example", "yes"]
// Invalid examples:
//	[example, example, example]
//  ['example, example, example]
pub fn (params &Params) get_list(key string) ![]string {
	mut res := []string{}
	mut valuestr := params.get(key)!
	valuestr = valuestr.trim('[] ,')
	mut j := 0
	mut i := 0
	for i < valuestr.len {
		if valuestr[i] == 34 || valuestr[i] == 39 { // handle single or double quotes
			quote := valuestr[i..i + 1]
			j = valuestr.index_after('${quote}', i + 1)
			if j == -1 {
				return error('Invalid list at index ${i}: strings should surrounded by single or double quote')
			}
			if i + 1 < j {
				res << valuestr[i + 1..j]
				i = j + 1
				if i < valuestr.len && valuestr[i] != 44 { // handle comma
					return error('Invalid list at index ${i}: strings should be separated by a comma')
				}
			}
		} else if valuestr[i] == 32 { // handle space
		} else {
			return error('Invalid list at index ${i}: unexpected character at location ${i}, items in a list of strings should start with single or double quotes')
		}
		i += 1
	}
	return res
}

// Looks for a list of strings in the parameters. If it doesn't exist this function the provided default value. Furthermore an error will be returned if the parameter exists and it's not a valid list.
// Please look at get_list for examples of valid and invalid lists
pub fn (params &Params) get_list_default(key string, def []string) ![]string {
	if params.exists(key) {
		return params.get_list(key)
	}
	return def
}

// Looks for a list of strings in the parameters. If it doesn't exist this function returns an error. Furthermore an error will be returned if the parameter exists and it's not a valid list.
// The items in the list will be namefixed
pub fn (params &Params) get_list_namefix(key string) ![]string {
	mut res := params.get_list(key)!
	return res.map(texttools.name_fix(it))
}

// Looks for a list of strings in the parameters. If it doesn't exist this function returns the provided default value. Furthermore an error will be returned if the parameter exists and it's not a valid list.
// The items in the list will be namefixed
pub fn (params &Params) get_list_namefix_default(key string, def []string) ![]string {
	if params.exists(key) {
		res := params.get_list(key)!
		return res.map(texttools.name_fix(it))
	}
	return def
}

fn (params &Params) get_list_numbers(key string) ![]string {
	mut valuestr := params.get(key)!
	valuestr = valuestr.trim('[] ')
	return valuestr.split(', ')
}

// Looks for a list of u8 with the provided key. If it does not exist an error is returned.
pub fn (params &Params) get_list_u8(key string) ![]u8 {
	mut res := params.get_list_numbers(key)!
	return res.map(u8(strconv.parse_uint(it, 10, 8) or {
		return error('${key} list entry ${it} is not a valid unsigned 8-bit integer')
	}))
}

// Looks for a list of u8 with the provided key. If it does not exist the provided default value is returned.
pub fn (params &Params) get_list_u8_default(key string, def []u8) []u8 {
	if params.exists(key) {
		res := params.get_list_numbers(key) or { return def }
		return res.map(it.u8())
	}
	return def
}

// Looks for a list of u16 with the provided key. If it does not exist an error is returned.
pub fn (params &Params) get_list_u16(key string) ![]u16 {
	mut res := params.get_list_numbers(key)!
	return res.map(u16(strconv.parse_uint(it, 10, 16) or {
		return error('${key} list entry ${it} is not a valid unsigned 16-bit integer')
	}))
}

// Looks for a list of u16 with the provided key. If it does not exist the provided default value is returned.
pub fn (params &Params) get_list_u16_default(key string, def []u16) []u16 {
	if params.exists(key) {
		res := params.get_list_numbers(key) or { return def }
		return res.map(it.u16())
	}
	return def
}

// Looks for a list of u32 with the provided key. If it does not exist an error is returned.
pub fn (params &Params) get_list_u32(key string) ![]u32 {
	mut res := params.get_list_numbers(key)!
	return res.map(u32(strconv.parse_uint(it, 10, 32) or {
		return error('${key} list entry ${it} is not a valid unsigned 32-bit integer')
	}))
}

// Looks for a list of u32 with the provided key. If it does not exist the provided default value is returned.
pub fn (params &Params) get_list_u32_default(key string, def []u32) []u32 {
	if params.exists(key) {
		res := params.get_list_numbers(key) or { return def }
		return res.map(it.u32())
	}
	return def
}

// Looks for a list of u64 with the provided key. If it does not exist an error is returned.
pub fn (params &Params) get_list_u64(key string) ![]u64 {
	res := params.get_list_numbers(key)!
	return res.map(strconv.parse_uint(it, 10, 64) or {
		return error('${key} list entry ${it} is not a valid unsigned 64-bit integer')
	})
}

// Looks for a list of u64 with the provided key. If it does not exist the provided default value is returned.
pub fn (params &Params) get_list_u64_default(key string, def []u64) []u64 {
	if params.exists(key) {
		res := params.get_list_numbers(key) or { return def }
		return res.map(it.u64())
	}
	return def
}

// Looks for a list of i8 with the provided key. If it does not exist an error is returned.
pub fn (params &Params) get_list_i8(key string) ![]i8 {
	mut res := params.get_list_numbers(key)!
	return res.map(i8(strconv.atoi(it) or {
		return error('${key} list entry ${it} is not a valid signed 8-bit integer')
	}))
}

// Looks for a list of i8 with the provided key. If it does not exist the provided default value is returned.
pub fn (params &Params) get_list_i8_default(key string, def []i8) []i8 {
	if params.exists(key) {
		res := params.get_list_numbers(key) or { return def }
		return res.map(it.i8())
	}
	return def
}

// Looks for a list of i16 with the provided key. If it does not exist an error is returned.
pub fn (params &Params) get_list_i16(key string) ![]i16 {
	mut res := params.get_list_numbers(key)!
	return res.map(i16(strconv.atoi(it) or {
		return error('${key} list entry ${it} is not a valid signed 16-bit integer')
	}))
}

// Looks for a list of i16 with the provided key. If it does not exist the provided default value is returned.
pub fn (params &Params) get_list_i16_default(key string, def []i16) []i16 {
	if params.exists(key) {
		res := params.get_list_numbers(key) or { return def }
		return res.map(it.i16())
	}
	return def
}

// Looks for a list of int with the provided key. If it does not exist an error is returned.
pub fn (params &Params) get_list_int(key string) ![]int {
	mut res := params.get_list_numbers(key)!
	return res.map(strconv.atoi(it) or {
		return error('${key} list entry ${it} is not a valid signed 32-bit integer')
	})
}

// Looks for a list of int with the provided key. If it does not exist the provided default value is returned.
pub fn (params &Params) get_list_int_default(key string, def []int) []int {
	if params.exists(key) {
		res := params.get_list_numbers(key) or { return def }
		return res.map(it.int())
	}
	return def
}

// Looks for a list of i64 with the provided key. If it does not exist an error is returned.
pub fn (params &Params) get_list_i64(key string) ![]i64 {
	mut res := params.get_list_numbers(key)!
	return res.map(strconv.parse_int(it, 10, 64) or {
		return error('${key} list entry ${it} is not a valid signed 64-bit integer')
	})
}

// Looks for a list of i64 with the provided key. If it does not exist the provided default value is returned.
pub fn (params &Params) get_list_i64_default(key string, def []i64) []i64 {
	if params.exists(key) {
		res := params.get_list_numbers(key) or { return def }
		return res.map(it.i64())
	}
	return def
}

// Looks for a list of f32 with the provided key. If it does not exist an error is returned.
pub fn (params &Params) get_list_f32(key string) ![]f32 {
	mut res := params.get_list_numbers(key)!
	return res.map(f32(strconv.atof64(it)!))
}

// Looks for a list of f32 with the provided key. If it does not exist the provided default value is returned.
pub fn (params &Params) get_list_f32_default(key string, def []f32) []f32 {
	if params.exists(key) {
		res := params.get_list_numbers(key) or { return def }
		return res.map(it.f32())
	}
	return def
}

// Looks for a list of f64 with the provided key. If it does not exist an error is returned.
pub fn (params &Params) get_list_f64(key string) ![]f64 {
	mut res := params.get_list_numbers(key)!
	return res.map(strconv.atof64(it)!)
}

// Looks for a list of f64 with the provided key. If it does not exist the provided default value is returned.
pub fn (params &Params) get_list_f64_default(key string, def []f64) []f64 {
	if params.exists(key) {
		res := params.get_list_numbers(key) or { return def }
		return res.map(it.f64())
	}
	return def
}
