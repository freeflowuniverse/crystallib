module main

import freeflowuniverse.crystallib.data.knowledgetree
import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.core.pathlib

import os

const orgpath = os.dir(@FILE) + '/../data'
const workpath = '/tmp/booktest'

fn do() ! {

	mut p:=pathlib.get(orgpath)
	p.copy(dest:workpath,delete:true)! //make sure we have the destination in sync with source

	mut tree := knowledgetree.new(
		cid:smartid.cid_get(name:"testknowledgetree")!
	)!

	tree.scan(
		path: workpath
		heal: true
	)!

	//todo: test there are 2 collections and the names should be ok

	assert tree.page_exists("smallbook1:decentralized_cloud")
	assert tree.page_exists("smallbook2:decentralized_cloud")
	assert tree.page_exists("grant.md") //should work because there is only 1
	
	mut error:=false
	mypage:=tree.page_get("decentralized_cloud") or {error=true} //should fail because there are 2 now
	assert error


	//todo: test include works see /Users/despiegk1/code/github/freeflowuniverse/crystallib/examples/knowledgetree/data/smallbook2/decentralized_cloud.md
	
	//todo: generate the mdbook, see it works (see summary in the data dir)

	// println(mypage)

	println('OK')
}


fn main() {
	do() or { panic(err) }
}
