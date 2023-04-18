module library

import os
import freeflowuniverse.crystallib.markdowndocs
import freeflowuniverse.crystallib.pathlib

const testpath = os.dir(@FILE) + '/testdata/broken_chapter'

fn testsuite_end() {
	os.execute('git checkout $testpath')
}

fn test_link_update() ! {}

fn test_fix_external_link() ! {}

fn test_fix() ! {
	mut lib := new()
	mut book := lib.book_new(name: 'testbook')!
	mut test_chapter := book.chapter_new(
		name: 'Chapter1'
		path: library.testpath
	) or { panic('Cannot create new chapter: ${err}') }

	mut page_path := pathlib.get('${library.testpath}/wrong_links/page_with_wrong_links.md')
	mut test_page := test_chapter.page_new(mut page_path) or { panic('Cannot create page: ${err}') }

	test_page.fix() or { panic('Cannot fix page: ${err}') }

	assert test_page.changed
}

fn test_fix_links() ! {}

fn test_process_macro_include() {}

fn test_save() ! {}