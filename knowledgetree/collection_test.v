module knowledgetree

import os

const testpath = os.dir(@FILE) + '/example/collection1'

// const test_page = test_collection.page_new()

fn test_fix() ! {
	mut lib := new()!
	mut book := lib.book_new(name: 'testbook')!
	mut test_collection := lib.collection_new(
		name: 'Collection1'
		path: knowledgetree.testpath
	) or { panic('Cannot create new collection: ${err}') }

	test_collection.fix() or { panic('Cannot fix page: ${err}') }
}

fn test_scan() {
	mut lib := new()!
	mut book := lib.book_new(name: 'testbook')!
	mut test_collection := lib.collection_new(
		name: 'Collection2'
		path: knowledgetree.testpath
		load: true
		heal: false
	) or { panic('Cannot create / load new collection: ${err}') }

	println(test_collection)
}


//TODO: needs to be checked