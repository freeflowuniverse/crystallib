module main

import freeflowuniverse.crystallib.books

import os

const testpath = os.dir(@FILE) + '/book1'


fn do()? {

	mut s:=books.new()
	s.site_new(path:testpath)?
	s.scan()?

}

fn main() {

	do() or {panic(err)}

}
