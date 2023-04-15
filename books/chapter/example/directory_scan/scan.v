module main

import freeflowuniverse.crystallib.books.chapter
import os

const testpath = os.dir(@FILE) + '/../chapter1'

fn do() ! {
	mut c := chapter.chapter_new(path: testpath
		load: true
		heal: false	
		name: 'Scanner1'
	)!


	assert c.page_exists("grant")
	assert c.page_exists("grant3") == false
	assert c.image_exists("centralized_internet.jpg")
	assert c.image_exists("centralized_internet_.jpg")
	mut i:=c.image_get("centralized_internet_.jpg")!
	println(i)
	assert c.image_exists("smart_contract_it")
	assert c.image_exists("smart_contractit")==false


	println(c)
}

fn main() {
	do() or { panic(err) }
}
