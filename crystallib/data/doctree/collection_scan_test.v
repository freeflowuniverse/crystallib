module doctree

import os

const testpath = os.dir(@FILE) + '/example/chapter1'
const fruits_path = os.dir(@FILE) + '/testdata/collections/fruits'
const tree_name = 'collection_scan_test_tree'

fn test_scan_internal() ! {
	mut tree := tree_create(cid: 'abc', name: 'test')!

	mut collection := tree.collection_new(
		name: 'fruits'
		path: doctree.fruits_path
		heal: false
		load: false
	)!

	collection.scan_internal(mut collection.path)!

	// test pages are scanned correctly
	assert collection.pages.len == 3
	assert 'apple' in collection.pages.keys()
	assert 'strawberry' in collection.pages.keys()
	assert 'intro' in collection.pages.keys()
	assert collection.pages.values().all(os.exists(it.path.path))

	// test files are scanned correctly
	assert collection.files.len == 1
	assert 'banana' in collection.files.keys()
	assert collection.files.values().all(os.exists(it.path.path))

	assert collection.errors.len == 0
}
