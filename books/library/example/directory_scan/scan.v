module main

import freeflowuniverse.crystallib.books.library
import os

const testpath = os.dir(@FILE) + '/../chapter1'

fn do() ! {

	mut l := library.new()
	
	mut book:=l.book_new(name:"testbook")!

	mut c := book.chapter_new(
		path: testpath
		load: true
		heal: false
		name: 'Scanner1'
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
	println(page)

	// println(c)
}

fn main() {
	do() or { panic(err) }
}
