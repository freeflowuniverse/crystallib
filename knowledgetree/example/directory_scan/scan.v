module main

import freeflowuniverse.crystallib.knowledgetree
import os

const testpath = os.dir(@FILE) + '/../chapter1'

fn do() ! {
	mut tr := knowledgetree.new()!

	tr.scan(path: testpath, heal: false)!

	mut c := tr.collection_get('solution')!

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
	// println(c)

	mut book := tr.book_new(path: '${testpath}', name: 'mybook')!
	book.read()! // will generate and open
	println(book)
}

fn main() {
	do() or { panic(err) }
}
