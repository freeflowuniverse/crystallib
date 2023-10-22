module main

import freeflowuniverse.crystallib.data.knowledgetree
import freeflowuniverse.crystallib.baobab.smartid
import os

const testpath = os.dir(@FILE) + '/../data'

fn do() ! {
	mut tree := knowledgetree.new(
		cid:smartid.cid_get(name:"testknowledgetree")!
	)!

	tree.scan(
		path: testpath
		heal: false
	)!


	println(tree)

	println('OK')
}


fn main() {
	do() or { panic(err) }
}
