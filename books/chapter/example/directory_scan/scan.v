module main

import freeflowuniverse.crystallib.books.chapter
import os

const testpath = os.dir(@FILE) + '/chapter1'

fn do() ! {
	c := chapter.chapter_new(path: testpath
		load: true
		heal: false	
		name: 'My Test Scan'
	)!
	println(c)
}

fn main() {
	do() or { panic(err) }
}
