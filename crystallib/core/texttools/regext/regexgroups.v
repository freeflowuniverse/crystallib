module regext

import regex


// find parts of text which are in form {NAME}
// .
// NAME is as follows: .
//   Lowercase letters: a-z .
//   Digits: 0-9 .
//   Underscore: _ .
// .
// will return list of the found NAME's
pub fn find_simple_vars(txt string) []string {
	pattern := r'\{(\w+)\}'
	mut re := regex.regex_opt(pattern) or { panic(err) }

	mut words := re.find_all_str(txt)

	words = words.map(it.trim('{} '))
	return words
}

fn remove_sid(c string) string {
	if c.starts_with('sid:') {
		return c[4..].trim_space()
	}
	return c
}

// find parts of text in form sid:abc till sid:abcde  (can be a...z 0...9) .
// return list of the found elements .
// to make all e.g. lowercase do e.g. words = words.map(it.to_lower()) after it
pub fn find_sid(txt string) []string {
	pattern := r'sid:[a-zA-Z0-9]{3,5}[\s$]'
	mut re := regex.regex_opt(pattern) or { panic(err) }

	mut words := re.find_all_str(txt)
	// words = words.map(it.to_lower())
	words = words.map(remove_sid(it))
	return words
}
