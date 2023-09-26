module knowledgetree

import os

const testpath = os.dir(@FILE) + '/example/chapter1'

const collections_path = os.dir(@FILE) + '/testdata/collections'

const tree_name = 'collection_test_tree'

fn testsuite_begin() {
	new(name: knowledgetree.tree_name)!
}

fn test_fix() ! {
	mut tree := knowledgetrees[knowledgetree.tree_name]
	// mut book := book_create(
	// 	name: 'book1'
	// 	path: knowledgetree.book1_path
	// 	dest: knowledgetree.book1_dest
	// 	tree_name: knowledgetree.tree_name
	// )!

	mut test_collection := tree.collection_new(
		name: 'Collection1'
		path: knowledgetree.testpath
	) or { panic('Cannot create new collection: ${err}') }

	test_collection.fix() or { panic('Cannot fix page: ${err}') }
}

// fn test_scan() {
// 	mut book := lib.book_new(name: 'testbook', path: knowledgetree.testpath)!
// 	mut test_collection := lib.collection_new(
// 		name: 'Collection2'
// 		path: knowledgetree.testpath
// 		load: true
// 		heal: false
// 	)
// }
