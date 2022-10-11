module main

import freeflowuniverse.crystallib.books
import os

// const testpath = os.dir(@FILE) + '/book1'
const path = '~/code/github/threefoldfoundation/books/content'

fn do() ? {
	mut books := books.new()
	books.scan(path)?
	books.fix()?
	// println(books.sites["mytwin"])
	// books.mdbook_export()?
	// site.mdbook_develop()?
}

fn main() {
	println('ERROR IN MAIN')
	do() or { panic(err) }
}


//git reset --hard && git clean -fxd