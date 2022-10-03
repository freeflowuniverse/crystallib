module main

import freeflowuniverse.crystallib.books
import os

const testpath = os.dir(@FILE) + '/book1'

fn do() ? {
	mut s := books.new()
	site := s.site_new(path: main.testpath)?
	s.scan()?
	site.mdbook_export()?
	site.mdbook_develop()?
}

fn main() {
	do() or { panic(err) }
}
