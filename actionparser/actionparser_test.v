module actionparser

import os

const testpath = os.dir(@FILE) + '/test_content'

// fn test_read() {
// 	mut parser := get()

// 	parser.file_parse('$actionparser.testpath/launch.md') or { panic('cannot parse,$err') }

// 	println(parser.actions)

// 	panic('sss')
// }
