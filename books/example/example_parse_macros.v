module main

import freeflowuniverse.crystallib.books
import gittools
import os

const testpath = os.dir(@FILE) + '/test_content'

fn do() ? {
}

fn main() {
	do() or { panic(err) }
}
