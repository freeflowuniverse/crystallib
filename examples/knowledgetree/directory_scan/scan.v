module main

import freeflowuniverse.crystallib.data.knowledgetree
import freeflowuniverse.crystallib.baobab.smartid
import os

const testpath = os.dir(@FILE) + '/../data'

fn main() {
	do() or { panic(err) }
}
