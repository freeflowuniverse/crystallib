module main2

import freeflowuniverse.crystallib.books
import os

const testpath = os.dir(@FILE) + '/book1'

fn do() ? {
	mut s := books.new()
	site := s.site_new(path: main2.testpath)?
	s.scan()?
	site.mdbook_export()?
	site.mdbook_develop()?
}

fn main2() {
	do() or { panic(err) }
}
