module doctree

import log
import v.embed_file
// import freeflowuniverse.crystallib.baobab.spawner
// import freeflowuniverse.crystallib.baobab.context
import os

const (
	collections_path = os.dir(@FILE) + '/testdata/collections'
	tree_name        = 'tree_test_tree'
	book1_path       = os.dir(@FILE) + '/testdata/book1'
	book1_dest       = os.dir(@FILE) + '/testdata/_book1'
)

fn test_init() ! {
	mut tree := Tree{}
	tree.init()!
	assert tree.embedded_files.len == 6
}

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
	new(name: doctree.tree_name)!
	scan(
		name: doctree.tree_name
		path: doctree.collections_path
	)!
	tree := knowledgetrees[doctree.tree_name]

	// these page pointers are correct and page_get should work
	apple_ptr_correct0 := 'fruits:apple.md'
	apple_ptr_correct1 := 'apple.md'
	apple_ptr_correct2 := 'apple'

	if page := tree.page_get(apple_ptr_correct0) {
		assert page.name == 'apple'
	} else {
		assert false
	}
	if page := tree.page_get(apple_ptr_correct1) {
		assert page.name == 'apple'
	} else {
		assert false
	}
	if page := tree.page_get(apple_ptr_correct2) {
		assert page.name == 'apple'
	} else {
		assert false
	}

	// these page pointers are incorrect but page_get should still work
	apple_ptr_incorrect0 := 'incorrect/apple.md'
	apple_ptr_incorrect1 := 'fruits:incorrect/apple.md'
	apple_ptr_incorrect2 := 'fruits:incorrect/apple'

	if page := tree.page_get(apple_ptr_incorrect0) {
		assert page.name == 'apple'
	} else {
		assert false
	}
	if page := tree.page_get(apple_ptr_incorrect1) {
		assert page.name == 'apple'
	} else {
		assert true
	}
	if page := tree.page_get(apple_ptr_incorrect2) {
		assert page.name == 'apple'
	} else {
		assert true
	}

	// these page pointers are faulty
	apple_ptr_faulty0 := 'nonexistent:apple.md'
	apple_ptr_faulty1 := 'appple.md'

	if page := tree.page_get(apple_ptr_faulty0) {
		assert false
	} else {
		assert true
	}
	if page := tree.page_get(apple_ptr_faulty1) {
		assert false
	} else {
		assert true
	}
}
