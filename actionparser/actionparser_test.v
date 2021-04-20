module actionparser

fn test_read() {
	res := parse('actionparser/launch.md') or { panic('cannot parse') }
	println(res)
	panic('sss')
}
