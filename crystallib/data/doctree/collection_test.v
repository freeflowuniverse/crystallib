module doctree

import os

const testpath = os.dir(@FILE) + '/example/chapter1'
const collections_path = os.dir(@FILE) + '/testdata/collections'

fn test_page_get() {
	mut tree := new(name: 'test')!
	tree.scan(
		path: doctree.collections_path
	)!

	apple_page_name := 'apple'
	fruits_collection_name := 'fruits'
	apple_page_path := '${os.dir(@FILE)}/testdata/collections/fruits/apple.md'

	// test with existing page
	collection := tree.collection_get(fruits_collection_name)!
	apple_page := collection.page_get(apple_page_name)!
	assert apple_page.path.path == apple_page_path

	strawberry_page_name := 'strawberry'
	strawberry_page_path := '${os.dir(@FILE)}/testdata/collections/fruits/berries/strawberry.md'

	// test with existing page in subdir of collection
	strawberry_page := collection.page_get(strawberry_page_name)!
	assert strawberry_page.path.path == strawberry_page_path

	// test with non-existing page
	nonexistent_page_name := 'nonexistent'
	if nonexistent_page := collection.page_get(nonexistent_page_name) {
		assert false
	} else {
		assert true
	}

	// test with page from another collection
	broccoli_page_name := 'broccoli'
	if broccoli_page := collection.page_get(broccoli_page_name) {
		assert false
	} else {
		assert true
	}
}

fn test_file_get() {
	mut tree := new(name: 'test')!
	tree.scan(
		path: doctree.collections_path
	)!

	banana_file_name := 'banana'
	banana_file_collection := 'fruits'
	banana_file_path := '${os.dir(@FILE)}/testdata/collections/fruits/banana.txt'

	// test with existing page
	collection := tree.collection_get(banana_file_collection)!
	banana_file := collection.file_get(banana_file_name)!
	assert banana_file.path.path == banana_file_path

	// test with non-existing page
	nonexistent_file_name := 'nonexistent'
	if nonexistent_file := collection.page_get(nonexistent_file_name) {
		assert false
	} else {
		assert true
	}

	// test with page from another collection
	cabbage_file_name := 'cabbage.txt'
	if cabbage_file := collection.page_get(cabbage_file_name) {
		assert false
	} else {
		assert true
	}
}

fn test_page_exists() {
	mut tree := new(name: 'test')!
	tree.scan(
		path: doctree.collections_path
	)!

	apple_page_name := 'apple'
	fruits_collection_name := 'fruits'

	// test with existing page
	collection := tree.collection_get(fruits_collection_name)!
	assert collection.page_exists(apple_page_name)

	// test with existing page in subdir of collection
	strawberry_page_name := 'strawberry'
	assert collection.page_exists(strawberry_page_name)

	// test with non-existing page
	nonexistent_page_name := 'nonexistent'
	assert !collection.page_exists(nonexistent_page_name)

	// test with page from another collection
	broccoli_page_name := 'broccoli'
	assert !collection.page_exists(broccoli_page_name)
}

fn test_file_exists() {
	mut tree := new(name: 'test')!
	tree.scan(
		path: doctree.collections_path
	)!

	banana_file_name := 'banana'
	fruits_collection_name := 'fruits'

	// test with existing page
	collection := tree.collection_get(fruits_collection_name)!
	assert collection.file_exists(banana_file_name)

	// test with non-existing page
	nonexistent_file_name := 'nonexistent'
	assert !collection.file_exists(nonexistent_file_name)

	// test with page from another collection
	cabbage_file_name := 'cabbage'
	assert !collection.file_exists(cabbage_file_name)
}
