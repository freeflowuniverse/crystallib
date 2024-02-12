module doctree

import os
import freeflowuniverse.crystallib.data.markdownparser.elements
import freeflowuniverse.crystallib.core.pathlib

const collections_path = os.dir(@FILE) + '/testdata/collections'

// IMPORTANT: we should never change the files on original location, copy out first

fn copy_to_testloc() ! {
	// put back the original data
	mut p := pathlib.get_dir(path: doctree.collections_path) or { panic('cant find collections') }
	p.copy(dest: '/tmp/tmp_doctree', delete: true)!
}

fn test_link_update() ! {}

fn test_fix_external_link() ! {}

fn test_fix() ! {
	copy_to_testloc()!
	mut tree := tree_create(cid: 'abc', name: 'test')!
	tree.scan(path: '/tmp/tmp_doctree')!

	mut test_collection := tree.collection_get('broken')!
	mut page_path := pathlib.get('/tmp/tmp_doctree/wrong_links/page_with_wrong_links.md')
	test_collection.page_new(mut page_path) or { panic('Cannot create page: ${err}') }
	mut test_page := test_collection.page_get('page_with_wrong_links')!

	doc_before := test_page.doc(dest: test_page.path.parent()!.path)! // or { panic('doesnt exist') }

	assert !test_page.changed // should be set to false after fix

	// assert test_page.doc or { panic('doesnt exist') } != doc_before // page was actually modified

	paragraph := doc_before.children[1]
	wrong_link := paragraph.children[1]
	if wrong_link is elements.Link {
		assert wrong_link.description == 'Image with wrong link'
		assert wrong_link.url == './threefold_supernode.jpg'
	} else {
		assert false, 'element ${wrong_link} is not a link'
	}

	right_link := paragraph.children[3]
	if right_link is elements.Link {
		assert right_link.description == 'Image with correct link'
		assert right_link.url == './img/threefold_supernode.jpg'
	} else {
		assert false, 'element ${right_link} is not a link'
	}

	test_page.fix() or { panic('Cannot fix page: ${err}') }
}

// tests collection errors are properly created
// TODO: get from copied locations
fn test_errors_created() {
	/*
		errors could happen because of:
			- duplicate files (images)
			- new page with non-unique name - ok
			- new file with non-unique name - ok
			- broken links - with cur implementation should never happen
			- "markdown file should not be linked"" - with cur implementation should never happen
	*/
	mut tree := tree_create(cid: 'abc', name: 'test')!
	tree.scan(path: '/tmp/tmp_doctree/errors', heal: true)!
	collection := tree.collection_get('errors')!
	assert collection.errors.len == 2
	assert collection.errors.filter(it.cat == .file_double).len == 1
	assert collection.errors.filter(it.cat == .page_double).len == 1
	collection.errors_report(testdata_path + '/errors/errors.md')!
}

/* TOCHECK:
	- errors.md file is created and has the errors
	- the links are properly repaired
	- the images are properly repaired (you will have to put 1 png in original dir, then check it becomes jpeg and link changed)
	- the markdown output is ok
*/
