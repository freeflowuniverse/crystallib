module paramsparser

pub fn (params &Params) get_email(key string) !string {
	mut valuestr := params.get(key)!
	return normalize_email(valuestr)
}

pub fn (params &Params) get_emails(key string) ![]string{
	mut valuestr := params.get(key)!
	valuestr = valuestr.trim('[] ')

	split := valuestr.split(',')
	mut res := []string{}
	for item in split{
		res << normalize_email(item)
	}

	return res
}

pub fn (params &Params) get_emails_default(key string, default []string) ![]string{
	if params.exists(key){
		return params.get_emails(key)!
	}
	
	mut res := []string{}
	for item in default{
		res << normalize_email(item)
	}

	return res
}

fn normalize_email(email string) string{
	return email.trim(' ').to_lower()
}