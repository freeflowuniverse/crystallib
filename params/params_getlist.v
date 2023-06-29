module params

import texttools

// get kwarg, and return list of string based on comma separation
pub fn (params &Params) get_list(key string) ![]string {
	mut res := []string{}
	mut valuestr := params.get(key)!
	valuestr = valuestr.trim('[] ,')
	mut j := 0
	mut i := 0
	for i < valuestr.len {
		if valuestr[i] == 34 || valuestr[i] == 39 { // " or '
			quote := valuestr[i .. i+1]
			j = valuestr.index_after("${quote}", i+1)
			if j == -1 {
				return error('Invalid list at index ${i}: strings should surrounded by single or double quote')
			}
			if i+1 < j {
				res << valuestr[i+1 .. j]
				i = j+1
				if i < valuestr.len && valuestr[i] != 44 { // ,
					return error('Invalid list at index ${i}: strings should be separated by a comma')
				}
				i += 1
			}
		} else {
			return error('Invalid list at index ${i}: unexpected character at location $i')
		}
	}
	return res
}

pub fn (params &Params) get_list_namefix(key string) ![]string {
	mut res := params.get_list(key)!
	return res.map(texttools.name_fix(it))
}

fn (params &Params) get_list_numbers(key string) ![]string {
	mut res := []string{}
	mut valuestr := params.get(key)!
	valuestr = valuestr.trim('[] ')
	return valuestr.split(', ')
}

pub fn (params &Params) get_list_u64_default(key string, def []u64) []u64 {
	if params.exists(key) {
		res := params.get_list_numbers(key) or {
			return def
		}
		return res.map(it.u64())
	}
	return def
}

pub fn (params &Params) get_list_u64(key string) ![]u64 {
	res := params.get_list_numbers(key)!
	return res.map(it.u64())
}

pub fn (params &Params) get_list_u32_default(key string, def []u32) []u32 {
	if params.exists(key) {
		res := params.get_list_numbers(key) or {
			return def
		}
		return res.map(it.u32())
	}
	return def
}

pub fn (params &Params) get_list_u32(key string) ![]u32 {
	mut res := params.get_list_numbers(key)!
	return res.map(it.u32())
}

pub fn (params &Params) get_list_u8_default(key string, def []u8) []u8 {
	if params.exists(key) {
		res := params.get_list_numbers(key) or {
			return def
		}
		return res.map(it.u8())
	}
	return def
}

pub fn (params &Params) get_list_u8(key string) ![]u8 {
	mut res := params.get_list_numbers(key)!
	return res.map(it.u8())
}

pub fn (params &Params) get_list_uf64_default(key string, def []f64) []f64 {
	if params.exists(key) {
		res := params.get_list_numbers(key) or {
			return def
		}
		return res.map(it.f64())
	}
	return def
}

pub fn (params &Params) get_list_f64(key string) ![]f64 {
	mut res := params.get_list_numbers(key)!
	return res.map(it.f64())
}

pub fn (params &Params) get_list_int_default(key string, def []int) []int {
	if params.exists(key) {
		res := params.get_list_numbers(key) or {
			return def
		}
		return res.map(it.int())
	}
	return def
}

pub fn (params &Params) get_list_int(key string) ![]int {
	mut res := params.get_list_numbers(key)!
	return res.map(it.int())
}
