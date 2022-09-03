module main
import actionparser
import os

const testpath = os.dir(@FILE) + '/test_content'

fn do() ? {
	mut parser := actionparser.get()

	actionparser.file_parse('$testpath/launch.md') or { panic('cannot parse,$err') }

	println(parser.actions)

	panic('sss')
}

fn main() {
	do() or { panic(err) }
}
