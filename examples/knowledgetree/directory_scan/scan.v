module main

import freeflowuniverse.crystallib.data.knowledgetree
import os

const testpath = os.dir(@FILE) + '/../chapter1'

fn main() {
	do() or { panic(err) }
}
