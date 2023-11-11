// make sure that the names are always normalized so its easy to find them back
module texttools

const ignore_for_name = '\\/[]()?!@#$%^&*<>:;{}|~'

const keep_ascii = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()_-+={}[]"\':;?/>.<,|\\~` '

pub fn name_clean(r string) string {
	mut res := []string{}
	for ch in r {
		mut c := ch.ascii_str()
		if texttools.ignore_for_name.contains(c) {
			continue
		}
		res << c
	}
	return res.join('')
}

// remove all chars which are not ascii
pub fn ascii_clean(r string) string {
	mut res := []string{}
	for ch in r {
		mut c := ch.ascii_str()
		if texttools.keep_ascii.contains(c) {
			res << c
		}
	}
	return res.join('')
}

// https://en.wikipedia.org/wiki/Unicode#Standardized_subsets

pub fn remove_empty_lines(text string) string {
	mut out := []string{}
	for l in text.split_into_lines() {
		if l.trim_space() == '' {
			continue
		}
		out << l
	}
	return out.join('\n')
}
