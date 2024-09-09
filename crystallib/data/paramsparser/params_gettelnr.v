module paramsparser

pub fn (params &Params) get_telnr(key string) !string {
	mut valuestr := params.get(key)!
	return normalize_telnr(valuestr)
}


pub fn (params &Params) get_telnrs(key string) ![]string{
	mut valuestr := params.get(key)!
	valuestr = valuestr.trim('[] ')

	split := valuestr.split(',')
	mut res := []string{}
	for item in split{
		res << normalize_telnr(item)
	}

	return res
}

pub fn (params &Params) get_telnrs_default(key string, default []string) ![]string{
	if params.exists(key){
		return params.get_telnrs(key)!
	}
	
	mut res := []string{}
	for item in default{
		res << normalize_telnr(item)
	}

	return res
}

fn normalize_telnr(telnr string) string{
	mut value := telnr.trim('+ ')

	mut res := ''
	mut splitted := value.split('-')
	for item in splitted{
		res += item
	}

	return res
}