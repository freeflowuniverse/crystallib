module main

fn test1(x int) ?string {
	if x > 1 {
		return error('bad')
	}
	return '$x'
}

fn test2(testx int) string {
	x := test1(testx) or {
		// this makes x = "good" even when error
		// is a way how to get out of the option
		'good'
	}
	return x
}

assert test2(0) == '0'
assert test2(2) == 'good'
