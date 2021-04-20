import regex

struct TestObj {
	source string // source string to parse
	query  string // regex query string
	s      int    // expected match start index
	e      int    // expected match end index
}

const (
	tests = [
		TestObj{'this is a good.', r'this (\w+) a', 0, 9},
		TestObj{'this,these,those. over', r'(th[eio]se?[,. ])+', 0, 17},
		TestObj{'test1@post.pip.com, pera', r'[\w]+@([\w]+\.)+\w+', 0, 18},
		TestObj{'cpapaz ole. pippo,', r'.*c.+ole.*pi', 0, 14},
		TestObj{'adce aabe', r'(a(ab)+)|(a(dc)+)e', 0, 4},
	]
)

fn example() {
	for c, tst in tests {
		mut re := regex.new()
		re.compile_opt(tst.query) or {
			println(err)
			continue
		}
		// print the query parsed with the groups ids
		re.debug = 1 // set debug on at minimum level
		println('#${c:2d} query parsed: $re.get_query()')
		re.debug = 0
		// do the match
		start, end := re.match_string(tst.source)
		if start >= 0 && end > start {
			println('#${c:2d} found in: [$start, $end] => [${tst.source[start..end]}]')
		}
		// print the groups
		mut gi := 0
		for gi < re.groups.len {
			if re.groups[gi] >= 0 {
				println('group ${gi / 2:2d} :[${tst.source[re.groups[gi]..re.groups[gi + 1]]}]')
			}
			gi += 2
		}
		println('')
	}
}

fn main() {
	example()
}
