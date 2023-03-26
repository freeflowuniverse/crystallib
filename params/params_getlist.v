module params

import texttools
import os
import time { Duration }


// get kwarg, and return list of string based on comma separation
pub fn (params &Params) get_list(key string) ![]string {
	mut res := []string{}
	if params.exists(key) {
		mut valuestr := params.get(key)!
		if valuestr.contains(',') {
			valuestr = valuestr.trim('[] ,')
			res = valuestr.split(',').map(it.trim(' \'"')) 
			//BACKLOG: is not good enough, we need to parse better, this can give errors
		} else {
			res = [valuestr.trim('[] \'"')]
		}
	}
	return res
}

pub fn (params &Params) get_list_u32(key string) ![]u32 {
	mut res := params.get_list(key)!
	return res.map(it.u32())
}

pub fn (params &Params) get_list_f64(key string) ![]f64 {
	mut res := params.get_list(key)!
	return res.map(it.f64())
}


pub fn (params &Params) get_list_namefix(key string) ![]string {
	mut res := params.get_list(key)!
	res = res.map(texttools.name_fix(it))
	return res
}

// get kwarg, and return list of ints
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (params &Params) get_list_int(key string) ![]int {
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
