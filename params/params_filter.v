module params

[params]
pub struct ParamsFilter {
pub mut:
	include []string
	exclude []string
}

// will return true if the params object match the filter (include and excludes)
// will first do the include filter then exclude, which means if matched and exclude is then matched won't count
// uses the filter_item function for each include or excluse (see further)
pub fn (mut params Params) filter_match(myfilter ParamsFilter) !bool {
	mut inclok := true
	if myfilter.include.len > 0 {
		inclok = false
		for incl in myfilter.include {
			ok := params.filter_match_item(incl)!
			if ok {
				inclok = true
				break // not more needed to check includes, we found one
			}
		}
	}
	if inclok == false {
		return false
	}
	// no need to continue
	if myfilter.exclude.len > 0 {
		for excl in myfilter.exclude {
			ok2 := params.filter_match_item(excl)!
			if ok2 {
				return false
			}
		}
	}
	return true
}

// match params for 1 string based match
// can be e.g.
//    - hr+development, means look for argument hr or development
//    - devel*, look for an argument which starts with devel (see match_glob)
//    - color:*red*, look for a value with key color, which has 'red' string inside
//
// 	match_glob matches the string, with a Unix shell-style wildcard pattern
// 	The special characters used in shell-style wildcards are:
//     * - matches everything
//     ? - matches any single character
//	   [seq] - matches any of the characters in the sequence
//     [^seq] - matches any character that is NOT in the sequence
//     Any other character in pattern, is matched 1:1 to the corresponding character in name, including / and .
//     You can wrap the meta-characters in brackets too, i.e. [?] matches ? in the string, and [*] matches * in the string.
pub fn (mut params Params) filter_match_item(myfilter string) !bool {
	mut tests := [myfilter]
	if myfilter.contains('+') {
		tests = myfilter.split('+')
	}
	mut totalfound := 0
	for test in tests {
		mut found := false
		mut key := ''
		mut value := test.trim_space()
		if test.contains(':') {
			splitted := test.split(':')
			key = splitted[0]
			value = splitted[1]
			key = key.trim_space()
			value = value.trim_space()
		}
		if key == '' {
			for arg in params.args {
				if value.contains('*') || value.contains('[]') || value.contains('?') {
					// we will do match_glob 					
					if arg.match_glob(value) {
						found = true
					}
				} else {
					if arg == value {
						found = true
					}
				}
			}
		} else {
			for param in params.params {
				if param.key == key {
					if value.contains('*') || value.contains('[]') || value.contains('?') {
						// we will do match_glob 					
						if param.value.match_glob(value) {
							found = true
						}
					} else {
						if param.value == value {
							found = true
						}
					}
				}
			}
		}
		if found {
			totalfound += 1
		}
	}
	if tests.len == totalfound {
		return true
	}
	return false
}
