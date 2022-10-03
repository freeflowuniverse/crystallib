module main

import freeflowuniverse.crystallib.books
import os

const testpath = os.dir(@FILE) + '/book1'

fn do() ? {
	mut books := books.new()
	books.scan('~/code4/books/content')?
	// println(books.sites["mytwin"])
	books.mdbook_export()?
	// site.mdbook_develop()?
}

fn main() {
	println('ERROR IN MAIN')
	do() or { panic(err) }
}
