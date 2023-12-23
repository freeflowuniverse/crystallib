module doctree

import os

const testpath = os.dir(@FILE) + '/example/chapter1'
const playbooks_path = os.dir(@FILE) + '/testdata/playbooks'

fn test_page_get() {
	mut tree := tree_create(cid: 'abc', name: 'test')!
	tree.scan(
		path: doctree.playbooks_path
	)!

	apple_page_name := 'apple'
	fruits_playbook_name := 'fruits'
	apple_page_path := '${os.dir(@FILE)}/testdata/playbooks/fruits/apple.md'

	// test with existing page
	playbook := tree.playbook_get(fruits_playbook_name)!
	apple_page := playbook.page_get(apple_page_name)!
	assert apple_page.path.path == apple_page_path

	strawberry_page_name := 'strawberry'
	strawberry_page_path := '${os.dir(@FILE)}/testdata/playbooks/fruits/berries/strawberry.md'

	// test with existing page in subdir of playbook
	strawberry_page := playbook.page_get(strawberry_page_name)!
	assert strawberry_page.path.path == strawberry_page_path

	// test with non-existing page
	nonexistent_page_name := 'nonexistent'
	if nonexistent_page := playbook.page_get(nonexistent_page_name) {
		assert false
	} else {
		assert true
	}

	// test with page from another playbook
	broccoli_page_name := 'broccoli'
	if broccoli_page := playbook.page_get(broccoli_page_name) {
		assert false
	} else {
		assert true
	}
}

fn test_file_get() {
	mut tree := tree_create(cid: 'abc', name: 'test')!
	tree.scan(
		path: doctree.playbooks_path
	)!

	banana_file_name := 'banana'
	banana_file_playbook := 'fruits'
	banana_file_path := '${os.dir(@FILE)}/testdata/playbooks/fruits/banana.txt'

	// test with existing page
	playbook := tree.playbook_get(banana_file_playbook)!
	banana_file := playbook.file_get(banana_file_name)!
	assert banana_file.path.path == banana_file_path

	// test with non-existing page
	nonexistent_file_name := 'nonexistent'
	if nonexistent_file := playbook.page_get(nonexistent_file_name) {
		assert false
	} else {
		assert true
	}

	// test with page from another playbook
	cabbage_file_name := 'cabbage.txt'
	if cabbage_file := playbook.page_get(cabbage_file_name) {
		assert false
	} else {
		assert true
	}
}

fn test_page_exists() {
	mut tree := tree_create(cid: 'abc', name: 'test')!
	tree.scan(
		path: doctree.playbooks_path
	)!

	apple_page_name := 'apple'
	fruits_playbook_name := 'fruits'

	// test with existing page
	playbook := tree.playbook_get(fruits_playbook_name)!
	assert playbook.page_exists(apple_page_name)

	// test with existing page in subdir of playbook
	strawberry_page_name := 'strawberry'
	assert playbook.page_exists(strawberry_page_name)

	// test with non-existing page
	nonexistent_page_name := 'nonexistent'
	assert !playbook.page_exists(nonexistent_page_name)

	// test with page from another playbook
	broccoli_page_name := 'broccoli'
	assert !playbook.page_exists(broccoli_page_name)
}

fn test_file_exists() {
	mut tree := tree_create(cid: 'abc', name: 'test')!
	tree.scan(
		path: doctree.playbooks_path
	)!

	banana_file_name := 'banana'
	fruits_playbook_name := 'fruits'

	// test with existing page
	playbook := tree.playbook_get(fruits_playbook_name)!
	assert playbook.file_exists(banana_file_name)

	// test with non-existing page
	nonexistent_file_name := 'nonexistent'
	assert !playbook.file_exists(nonexistent_file_name)

	// test with page from another playbook
	cabbage_file_name := 'cabbage'
	assert !playbook.file_exists(cabbage_file_name)
}
