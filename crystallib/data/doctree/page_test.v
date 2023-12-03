module doctree

import os
import freeflowuniverse.crystallib.data.markdownparser.elements
import freeflowuniverse.crystallib.core.pathlib

const testpath = os.dir(@FILE) + '/testdata/broken_chapter'
const collections_path = os.dir(@FILE) + '/testdata/collections'
const tree_name = 'page_test_tree'

fn testsuite_end() {
	// reset testdata changes after running tests
	os.execute('git checkout ${doctree.testpath}')
}

fn create_tree() !Tree {
	new_global(name: doctree.tree_name)!
	scan(
		name: doctree.tree_name
		path: doctree.collections_path
	)!
	return knowledgetrees[doctree.tree_name]
}

fn test_link_update() ! {}

fn test_fix_external_link() ! {}

fn test_fix() ! {
	mut tree := create_tree()!
	mut test_collection := tree.collection_new(
		name: 'Collection1'
		path: doctree.testpath
	) or { panic('Cannot create new collection: ${err}') }

	mut page_path := pathlib.get('${doctree.testpath}/wrong_links/page_with_wrong_links.md')
	test_collection.page_new(mut page_path) or { panic('Cannot create page: ${err}') }
	mut test_page := test_collection.page_get('page_with_wrong_links.md')!

	doc_before := (*test_page).doc or { panic('doesnt exist') }
	// test_page.fix() or { panic('Cannot fix page: ${err}') }

	assert !test_page.changed // should be set to false after fix

	assert test_page.doc or { panic('doesnt exist') } != doc_before // page was actually modified

	paragraph := test_page.doc or { panic('doesnt exist') }.children[1]
	// wrong_link := paragraph.elements[1] as elements.Link
	// right_link := paragraph.elements[3] as elements.Link

	// assert wrong_link.path :=
	// println(test_page.doc)
	// panic('s')
}

fn test_fix_links() ! {}

fn test_process_macro_include() {}

fn test_save() ! {}
