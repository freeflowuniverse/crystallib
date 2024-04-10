module paramsparser

// Looks for a string of params in the parameters. If it doesn't exist this function will return an error. 
// Furthermore an error will be returned if the params is not properly formatted
pub fn (params &Params) get_params(key string) !Params {
	mut res := []string{}
	mut valuestr := params.get(key)!
	return parse(valuestr)!
}
