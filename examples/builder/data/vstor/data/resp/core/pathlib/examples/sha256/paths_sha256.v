module main

import freeflowuniverse.crystallib.pathlib
import os

const testpath4 = os.dir(@FILE) + '/test_path/test_parent/readme.md'

fn do() ! {
	mut p := pathlib.get_file(testpath4, false)!
	s := p.sha256()!
	println(s)
}

fn main() {
	do() or { panic(err) }
}
