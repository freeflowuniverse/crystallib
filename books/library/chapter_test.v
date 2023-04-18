module library

import os
import freeflowuniverse.crystallib.pathlib

const testpath = os.dir(@FILE) + '/example/chapter1'

// const test_page = test_chapter.page_new()

fn test_fix() ! {
	mut lib := new()
	mut book := book_new(name: 'testbook')!
	mut test_chapter := book.chapter_new(
		name: 'Chapter1'
		path: library.testpath
	) or { panic('Cannot create new chapter: ${err}') }

	mut page_path := pathlib.get('${library.testpath}/decentralized_cloud/decentralized_cloud.md')
	mut test_page := test_chapter.page_new(mut page_path) or { panic('Cannot create page: ${err}') }

	println(test_page)

	assert test_page.pathrel == 'decentralized_cloud/decentralized_cloud.md'
	assert test_page.name == 'decentralized_cloud'

	test_page.fix() or { panic('Cannot fix page: ${err}') }
}

fn test_scan() {
	mut lib := new()
	mut book := lib.book_new(name: 'testbook')!
	mut test_chapter := book.chapter_new(
		name: 'Chapter2'
		path: library.testpath
		load: true
		heal: false
	) or { panic('Cannot create / load new chapter: ${err}') }

	println(test_chapter)
}
