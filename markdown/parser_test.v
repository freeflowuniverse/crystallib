module markdown
import os
const testpath = os.dir(@FILE) + '/test_content'


fn test_1() {
	mut parser := get('${testpath}/launch.md') or { panic('cannot parse,$err') }

	println(parser.doc)

	panic('sss')
}
