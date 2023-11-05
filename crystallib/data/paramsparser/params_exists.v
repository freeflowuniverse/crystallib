module paramsparser

// check if kwarg exist
// line:
//    arg1 arg2 color:red priority:'incredible' description:'with spaces, lets see if ok
// arg1 is an arg
// description is a kwarg
pub fn (params &Params) exists(key_ string) bool {
	key := key_.to_lower().trim_space()
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
pub fn (params &Params) arg_exists(key_ string) bool {
	key := key_.to_lower().trim_space()
	for p in params.args {
		if p == key {
			return true
		}
	}
	return false
}
