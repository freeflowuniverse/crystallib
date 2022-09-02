module main

import freeflowuniverse.crystallib.markdown
import os

const testpath = os.dir(@FILE) + '/content'


fn do()? {

	mut parser := markdown.get('${testpath}/launch.md') or { panic('cannot parse,$err') }

	eprintln(parser.doc)

}

fn main() {

	do() or {panic(err)}

}
