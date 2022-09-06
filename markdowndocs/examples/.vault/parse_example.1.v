module main

import freeflowuniverse.crystallib.markdowndocs
import os

const testpath = os.dir(@FILE) + '/content'

fn do() ? {
	mut parser := markdowndocs.get('$testpath/launch.md') or { panic('cannot parse,$err') }

	mut o := parser.doc.items[1]
	if mut o is markdowndocs.Paragraph {
		eprintln(o.links)
	}
}

fn main() {
	do() or { panic(err) }
}
