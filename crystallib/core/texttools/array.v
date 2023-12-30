module texttools

// a comma or \n separated list gets converted to a list of strings .
//'..' also gets converted to without ''
pub fn toarray(r string) []string {
	mut res := []string{}
	mut r2 := r
	r2 = r2.replace(',', '\n')

	for mut line in r2.split_into_lines() {
		line = line.trim_space()
		if line == '' {
			continue
		}
		res << line.trim("'")
	}
	return res
}
