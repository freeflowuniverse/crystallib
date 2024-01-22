module doctree

import log
import v.embed_file
import freeflowuniverse.crystallib.data.markdownparser.elements
import os
import crypto.sha256
import freeflowuniverse.crystallib.core.pathlib

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

// pub fn (processor TestMacroProcessor) process(code string) !MacroResult {
// 	return MacroResult{}
// }

// TODO: remove???

// fn test_macroprocessor_add() {
// 	mut tree := Tree{}
// 	mp := TestMacroProcessor{}
// 	tree.macroprocessor_add(mp)!
// 	assert tree.macroprocessors.len == 1
// }

fn test_page_get() {
	mut tree := tree_create(name: doctree.tree_name)!
	tree.scan(
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

	// TODO: check if still needed
	// these page pointers are incorrect but page_get should still work
	// apple_ptr_incorrect0 := 'incorrect/apple.md'
	// apple_ptr_incorrect1 := 'fruits:incorrect/apple.md'
	// apple_ptr_incorrect2 := 'fruits:incorrect/apple'

	// page = tree.page_get(apple_ptr_incorrect0)!
	// assert page.name == 'apple'

	// page = tree.page_get(apple_ptr_incorrect1)!
	// assert page.name == 'apple'

	// page = tree.page_get(apple_ptr_incorrect2)!
	// assert page.name == 'apple'

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

fn match_files(mut files1 map[string]&File, mut files2 map[string]&File) ! {
	assert files1.len == files2.len
	for name, mut file1 in files1 {
		mut file2 := files2[name] or { return error("${name} doesn't exist in both collections") }
		file1_cont := file1.path.read()!
		file2_cont := file2.path.read()!
		if file1_cont != file2_cont {
			return error('${name} content mismatch')
		}
	}
}


fn match_pages(mut pages1 map[string]&Page, mut pages2 map[string]&Page) ! {
	assert pages1.len == pages2.len
	for name, mut page1 in pages1 {
		mut page2 := pages2[name] or { return error("${name} doesn't exist in both collections") }

		if page1_doc := page1.doc{
			if page2_doc := page2.doc{
				assert  page1_doc.markdown() == page2_doc.markdown()
			}else{
			return error("page2 doc not found")	
			}
		}else{
			return error("page1 doc not found")
		}
		
	}
}


fn match_collections(mut col1 Collection, mut col2 Collection) ! {
	match_files(mut col1.files, mut col2.files)!
	match_files(mut col1.images, mut col2.images)!
	match_pages(mut col1.pages, mut col2.pages)!
}

fn test_write_tree() {
	// read tree1
	mut tree1 := tree_create(name: doctree.tree_name)!
	tree1.scan(
		path: doctree.collections_path
	)!
	// write tree1 to another dir
	tree1.write('/tmp/tree_write')!
	// create tree2 from the written tree
	mut tree2 := tree_create(name: doctree.tree_name)!
	tree2.scan(path: '/tmp/tree_write')!
	tree2.write('/tmp/tree_write2')!
	// write tree2 another time to compare the output of the two 
	mut tree3 := tree_create(name: doctree.tree_name)!
	tree3.scan(path: '/tmp/tree_write2')!

	// assert the first tree matches the second one
	assert tree1.collections.len == tree2.collections.len
	for k, mut col1 in tree1.collections {
		mut col2 := tree2.collections[k] or { panic('collection ${k} is not in tree copy') }
		match_collections(mut *col1, mut *col2)!
	}
	// assert the first tree matches the third one
	assert tree1.collections.len == tree3.collections.len
	for k, mut col1 in tree1.collections {
		mut col3 := tree3.collections[k] or { panic('collection ${k} is not in tree copy') }
		match_collections(mut *col1, mut *col3)!
	}
}
