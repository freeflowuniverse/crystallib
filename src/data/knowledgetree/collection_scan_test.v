module knowledgetree

import freeflowuniverse.crystallib.pathlib
import os

const (
	testpath    = os.dir(@FILE) + '/example/chapter1'
	fruits_path = os.dir(@FILE) + '/testdata/collections/fruits'
	tree_name   = 'collection_scan_test_tree'
)

fn test_scan_internal() ! {
	new(name: knowledgetree.tree_name)!

	mut tree := knowledgetrees[knowledgetree.tree_name]
	mut collection := tree.collection_new(
		name: 'fruits'
		path: knowledgetree.fruits_path
		heal: false
		load: false
	)!

	collection.scan_internal(mut collection.path)!

	// test pages are scanned correctly
	assert collection.pages.len == 4
	assert 'apple' in collection.pages.keys()
	assert 'strawberry' in collection.pages.keys()
	assert 'errors' in collection.pages.keys()
	assert 'intro' in collection.pages.keys()
	assert collection.pages.values().all(os.exists(it.path.path))

	// test files are scanned correctly
	assert collection.files.len == 1
	assert 'banana' in collection.files.keys()
	assert collection.files.values().all(os.exists(it.path.path))

	assert collection.errors.len == 0
}
