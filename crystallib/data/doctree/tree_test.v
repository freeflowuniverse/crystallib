module doctree

import freeflowuniverse.crystallib.core.pathlib
import os

const collections_path = os.dir(@FILE) + '/testdata/collections'
const tree_name = 'tree_test_tree'
const book1_path = os.dir(@FILE) + '/testdata/book1'
const book1_dest = os.dir(@FILE) + '/testdata/_book1'

pub struct TestMacroProcessor {
}

fn test_page_get() {
	mut tree := new(name: doctree.tree_name)!
	tree.scan(
		path: doctree.collections_path
	)!

	mut page := tree.page_get('fruits:apple.md')!
	assert page.name == 'apple'

	page = tree.page_get('fruits:incorrect/apple.md')!
	assert page.name == 'apple'

	// these page pointers are faulty
	apple_ptr_faulty0 := 'nonexistent:apple.md'
	apple_ptr_faulty1 := 'apple.md'

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
	// errors are added so not same as original
	if 'errors' in pages1.keys() {
		pages1.delete('errors')
	}
	if 'errors' in pages2.keys() {
		pages2.delete('errors')
	}
	if pages1.len != pages2.len {
		println(pages1.keys().map(' - ${it}').join_lines())
		println('compared with:')
		println(pages2.keys().map(' - ${it}').join_lines())
		return error('nr of pages does not correspond in both collection')
	}
	for name, mut page1 in pages1 {
		mut page2 := pages2[name] or { return error("${name} doesn't exist in both collections") }

		page1_doc := page1.doc()!

		page2_doc := page2.doc()!
		mypath := page1_doc.path or { pathlib.Path{} }
		println(mypath.path)
		assert page1_doc.markdown().trim_space() == page2_doc.markdown().trim_space()
		// TODO: there is error, space at end of doc not the same, weird why trim_space doesn't resolve that, should also work without trim_space anyhow
	}
}

fn match_collections(mut col1 Collection, mut col2 Collection) ! {
	match_files(mut col1.files, mut col2.files)!
	match_files(mut col1.images, mut col2.images)!
	match_pages(mut col1.pages, mut col2.pages)!
}

fn test_write_tree() {
	// read tree1
	mut tree1 := new(name: doctree.tree_name)!
	tree1.scan(
		path: doctree.collections_path
	)!
	os.rmdir_all('/tmp/tree_write')!
	os.rmdir_all('/tmp/tree_write2')!
	// write tree1 to another dir
	tree1.export(dest: '/tmp/tree_write')!
	// create tree2 from the written tree
	mut tree2 := new(name: doctree.tree_name)!
	tree2.scan(path: '/tmp/tree_write')!
	tree2.export(dest: '/tmp/tree_write2')!
	// write tree2 another time to compare the output of the two
	mut tree3 := new(name: doctree.tree_name)!
	tree3.scan(path: '/tmp/tree_write2')!

	// TODO: can work with hash to check the full dir

	// assert the 1e tree matches the third one
	assert tree1.collections.len == tree3.collections.len
	for k, mut col1 in tree1.collections {
		mut col3 := tree3.collections[k] or { panic('collection ${k} is not in tree copy') }
		match_collections(mut *col1, mut *col3)!
	}

	// assert the 2nd tree matches the third one
	assert tree2.collections.len == tree3.collections.len
	for k, mut col2 in tree2.collections {
		mut col3 := tree3.collections[k] or { panic('collection ${k} is not in tree copy') }
		match_collections(mut *col2, mut *col3)!
	}
}
