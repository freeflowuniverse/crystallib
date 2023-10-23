module main

import freeflowuniverse.crystallib.data.knowledgetree
import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.core.pathlib

import os

const testpath = os.dir(@FILE) + '/../data'
const orgpath = os.dir(@FILE) + '/../data/smallbook_original'
const workpath = os.dir(@FILE) + '/../data/smallbook'

fn do() ! {

	mut p:=pathlib.get(orgpath)
	h:=p.md5hex()!
	// assert h=="5b7460284b629e31d57de2f9e146b107"

	p.copy(dest:workpath)!
	h2:=p.md5hex()!
	assert h2==h

	println(h)


	mut tree := knowledgetree.new(
		cid:smartid.cid_get(name:"testknowledgetree")!
	)!

	tree.scan(
		path: testpath
		heal: true
	)!


	assert tree.page_exists("decentralized_cloud")
	mypage:=tree.page_get("decentralized_cloud")!



	


	println(mypage)

	println('OK')
}


fn main() {
	do() or { panic(err) }
}
