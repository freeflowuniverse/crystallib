module main

import freeflowuniverse.crystallib.data.knowledgetree
import os

const testpath = os.dir(@FILE) + '/../chapter1'

fn do() ! {
	tree_name := 'Kapok'
	knowledgetree.new(name: tree_name)!
	knowledgetree.scan(
		name: tree_name
		path: testpath
		heal: false
	)!

	mut c := knowledgetree.collection_get(
		treename: tree_name
		name: 'solution'
	)!

	assert c.page_exists('grant')
	assert c.page_exists('grant3') == false
	assert c.image_exists('centralized_internet.jpg')
	assert c.image_exists('centralized_internet_.jpg')
	mut i := c.image_get('centralized_internet_.jpg')!
	println(i)
	assert c.image_exists('duplicate_centralized_internet.jpg')
	assert c.image_exists('duplicate_centralized_internets_.jpg') == false

	mut page := c.page_get('casperlabs_deployment')!
	mut page2 := c.page_get('casperlabs_Deployment')!
	assert page == page2

	// 	mut book := tr.book_new(path: '${testpath}', name: 'mybook')!
	// 	book.read()! // will generate and open
	// 	println(book)
}

fn main() {
	do() or { panic(err) }
}
