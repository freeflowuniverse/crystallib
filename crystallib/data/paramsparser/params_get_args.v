module paramsparser

pub fn (params &Params) len_arg() int {
	return params.args.len
}

// return the arg with nr, 0 is the first
pub fn (params &Params) get_arg(nr int) !string {
	if nr > params.args.len {
		return error('Looking for arg nr ${nr}, not enough args available.\n${params}')
	}
	return params.args[nr] or { panic('error, above should have catched') }
}

// return the arg with nr, 0 is the first
//check the length of the args
pub fn (params &Params) get_arg_check(nr int,checknrargs int) !string {
	params.check_arg_len(checknrargs)!
	return params.get_arg(nr)
}

pub fn (params &Params) check_arg_len(checknrargs int) ! {
	if checknrargs != params.args.len {
		return error('the amount of expected args is ${checknrargs}, we found different.\n${params}')
	}
}



// return arg, if the nr is larger than amount of args, will return the defval
pub fn (params &Params) get_arg_default(nr int, defval string) !string {
	if nr > params.args.len {
		return defval
	}
	r := params.get_arg(nr)!
	return r
}

// get arg return as int, if checknrargs is not 0, it will make sure the nr of args corresponds
pub fn (params &Params) get_arg_int(nr int) !int {
	r := params.get_arg(nr)!
	return r.int()
}

// get arg return as int. defval is the default value specified
pub fn (params &Params) get_arg_int_default(nr int, defval int) !int {
	r := params.get_arg_default(nr, '${defval}')!
	return r.int()
}
