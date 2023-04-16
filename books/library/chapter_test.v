module library

import os
import freeflowuniverse.crystallib.pathlib

const testpath = os.dir(@FILE) + '/example/directory_scan/chapter1'

// const test_page = test_chapter.page_new()

fn test_fix() {
	mut test_chapter := chapter_new(
		name: 'Chapter1'
		path: '${chapter.testpath}'
	) or { panic('Cannot create new chapter: ${err}') }

	mut page_path := pathlib.get('${chapter.testpath}/decentralized_cloud/decentralized_cloud.md')
	mut test_page := test_chapter.page_new(mut page_path) or { panic('Cannot create page: ${err}') }

	println(test_page)

	// test_page.fix() or { panic('Cannot fix page: ${err}') }

	assert test_page.pathrel == 'decentralized_cloud/decentralized_cloud.md'
	assert test_page.name == 'decentralized_cloud'
}

fn test_scan() {
	mut test_chapter := chapter_new(
		name: 'Chapter2'
		path: '${chapter.testpath}'
		load: true
		heal: false
	) or { panic('Cannot create / load new chapter: ${err}') }

	println(test_chapter)

	panic('Sd')
}
