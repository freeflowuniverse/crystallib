module library

import os
import freeflowuniverse.crystallib.pathlib

const testpath = os.dir(@FILE) + '/example/chapter1'

// const test_page = test_chapter.page_new()

fn test_fix() ! {
	mut lib := new()
	mut book := lib.book_new(name: 'testbook')!
	mut test_chapter := book.chapter_new(
		name: 'Chapter1'
		path: library.testpath
	) or { panic('Cannot create new chapter: ${err}') }

	test_chapter.fix() or { panic('Cannot fix page: ${err}') }
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
