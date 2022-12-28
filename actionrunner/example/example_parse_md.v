module main

import freeflowuniverse.crystallib.actionrunner
import os

const testpath = os.dir(@FILE) + '/test_content'

fn do() ? {
	actionrunner.execute('${testpath}/launch.md') or { panic('cannot parse,${err}') }
}

fn main() {
	do() or { panic(err) }
}
