module params

// return the arg with nr, 0 is the first
// if checknrargs==0 then won't check, if set, it means will check the nr of args if not correct will give error
pub fn (params &Params) get_arg(nr int, checknrargs int) !string {
	if checknrargs > 0 && checknrargs != params.args.len {
		return error('the amount of expected args is ${checknrargs}, we found different.\n${params}')
	}
	if nr > params.args.len {
		return error('Looking for arg nr ${nr}, not enough args available.\n${params}')
	}
	return params.args[nr] or { panic('error, above should have catched') }
}

// return arg, if the nr is larger than amount of args, will return the defval
pub fn (params &Params) get_arg_default(nr int, defval string) !string {
	if nr > params.args.len {
		return defval
	}
	r := params.get_arg(nr, 0)!
	return r
}

// get arg return as int, if checknrargs is not 0, it will make sure the nr of args corresponds
pub fn (params &Params) get_arg_int(nr int, checknrargs int) !int {
	r := params.get_arg(nr, checknrargs)!
	return r.int()
}

// get arg return as int. defval is the default value specified
pub fn (params &Params) get_arg_int_default(nr int, defval int) !int {
	r := params.get_arg_default(nr, '${defval}')!
	return r.int()
}
