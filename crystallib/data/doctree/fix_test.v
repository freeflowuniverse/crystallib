module doctree

import os
import freeflowuniverse.crystallib.data.markdownparser.elements
import freeflowuniverse.crystallib.core.pathlib

const testdata_path = os.dir(@FILE) + '/testdata'
const playbooks_path = os.dir(@FILE) + '/testdata/playbooks'
const playbooks_path_original = os.dir(@FILE) + '/testdata/original'

// TODO:  do good tests around fixing links, also images need to point to right location

fn restore() ! {
	// put back the original data
	mut p := pathlib.get_dir(path: doctree.playbooks_path_original) or {
		panic("can't restore original, do manual")
	}
	p.copy(dest: doctree.playbooks_path, delete: true)! // make sure all original is being restored for next test
}

fn test_link_update() ! {}

fn test_fix_external_link() ! {}

fn test_fix() ! {
	// defer {
	// 	// copy back the original
	// 	restore() or { println('failed to restore tree') }
	// }

	mut tree := tree_create(cid: 'abc', name: 'test')!
	tree.scan(path: doctree.playbooks_path)!

	mut test_playbook := tree.playbook_get('broken')!
	println('testcoll: ${test_playbook}')
	mut page_path := pathlib.get('${doctree.playbooks_path}/wrong_links/page_with_wrong_links.md')
	test_playbook.page_new(mut page_path) or { panic('Cannot create page: ${err}') }
	mut test_page := test_playbook.page_get('page_with_wrong_links')!

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

	test_page.fix() or { panic('Cannot fix page: ${err}') }
}

// tests playbook errors are properly created
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
	tree.scan(path: doctree.testdata_path + '/errors', heal: true)!
	playbook := tree.playbook_get('errors')!
	assert playbook.errors.len == 2
	assert playbook.errors.filter(it.cat == .file_double).len == 1
	assert playbook.errors.filter(it.cat == .page_double).len == 1
	playbook.errors_report(doctree.testdata_path + '/errors/errors.md')!
}

/*
	- errors.md file is created and has the errors
	- the links are properly repaired
	- the images are properly repaired (you will have to put 1 png in original dir, then check it becomes jpeg and link changed)
	- the markdown output is ok
*/
