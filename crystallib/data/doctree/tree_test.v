module doctree

import log
import v.embed_file
import freeflowuniverse.crystallib.data.markdownparser.elements
import os

const collections_path = os.dir(@FILE) + '/testdata/collections'
const tree_name = 'tree_test_tree'
const book1_path = os.dir(@FILE) + '/testdata/book1'
const book1_dest = os.dir(@FILE) + '/testdata/_book1'

// fn test_init() ! {
// 	mut tree := Tree{}
// 	tree.init()!
// 	assert tree.embedded_files.len == 6
// }

pub struct TestMacroProcessor {
}

pub fn (processor TestMacroProcessor) process(code string) !MacroResult {
	return MacroResult{}
}

fn test_macroprocessor_add() {
	mut tree := Tree{}
	mp := TestMacroProcessor{}
	tree.macroprocessor_add(mp)!
	assert tree.macroprocessors.len == 1
}

fn test_page_get() {
	mut tree := new(name: doctree.tree_name)!
	tree.scan(
		name: doctree.tree_name
		path: doctree.collections_path
	)!

	// these page pointers are correct and page_get should work
	apple_ptr_correct0 := 'fruits:apple.md'
	apple_ptr_correct1 := 'apple.md'
	apple_ptr_correct2 := 'apple'

	mut page := tree.page_get(apple_ptr_correct0)!
	assert page.name == 'apple'

	page = tree.page_get(apple_ptr_correct1)!
	assert page.name == 'apple'

	page = tree.page_get(apple_ptr_correct2)!
	assert page.name == 'apple'

	// these page pointers are incorrect but page_get should still work
	apple_ptr_incorrect0 := 'incorrect/apple.md'
	apple_ptr_incorrect1 := 'fruits:incorrect/apple.md'
	apple_ptr_incorrect2 := 'fruits:incorrect/apple'

	page = tree.page_get(apple_ptr_incorrect0)!
	assert page.name == 'apple'

	page = tree.page_get(apple_ptr_incorrect1)!
	assert page.name == 'apple'

	page = tree.page_get(apple_ptr_incorrect2)!
	assert page.name == 'apple'

	// these page pointers are faulty
	apple_ptr_faulty0 := 'nonexistent:apple.md'
	apple_ptr_faulty1 := 'appple.md'

	if p := tree.page_get(apple_ptr_faulty0) {
		assert false, 'this should fail: faulty pointer ${apple_ptr_faulty0}'
	}

	if p := tree.page_get(apple_ptr_faulty1) {
		assert false, 'this should fail: faulty pointer ${apple_ptr_faulty1}'
	}
}
