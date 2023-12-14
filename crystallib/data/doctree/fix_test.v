module doctree

import os
import freeflowuniverse.crystallib.data.markdownparser.elements
import freeflowuniverse.crystallib.core.pathlib

const collections_path = os.dir(@FILE) + '/testdata/collections'
const collections_path_original = os.dir(@FILE) + '/testdata/original'

// TODO:  do good tests around fixing links, also images need to point to right location

fn restore() {
	// put back the original data
	mut p := pathlib.dir_get(path: doctree.collections_path_original) or {
		panic("can't restore original, do manual")
	}
	p.copy(dest: doctree.collections_path, delete: true)! // make sure all original is being restored for next test
}

fn test_link_update() ! {}

fn test_fix_external_link() ! {}

fn test_fix() ! {
	defer {
		// copy back the original
		restore()
	}

	// TODO: this one is broken, need to fix and improve

	mut tree := tree_create(cid: 'abc', name: 'test')!
	tree.scan(path: doctree.collections_path)!

	mut test_collection := tree.collection_get('broken')!

	mut page_path := pathlib.get('${testpath}/wrong_links/page_with_wrong_links.md')
	test_collection.page_new(mut page_path) or { panic('Cannot create page: ${err}') }
	mut test_page := test_collection.page_get('page_with_wrong_links.md')!

	doc_before := (*test_page).doc or { panic('doesnt exist') }

	assert !test_page.changed // should be set to false after fix

	assert test_page.doc or { panic('doesnt exist') } != doc_before // page was actually modified

	paragraph := test_page.doc or { panic('doesnt exist') }.children[1]
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

	// test_page.fix() or { panic('Cannot fix page: ${err}') }
}