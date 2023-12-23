module doctree

import freeflowuniverse.crystallib.core.pathlib
import os

const testpath = os.dir(@FILE) + '/example/chapter1'
const fruits_path = os.dir(@FILE) + '/testdata/playbooks/fruits'
const tree_name = 'playbook_scan_test_tree'

fn test_scan_internal() ! {
	mut tree := tree_create(cid: 'abc', name: 'test')!

	mut playbook := tree.playbook_new(
		name: 'fruits'
		path: doctree.fruits_path
		heal: false
		load: false
	)!

	playbook.scan_internal(mut playbook.path)!

	// test pages are scanned correctly
	assert playbook.pages.len == 4
	assert 'apple' in playbook.pages.keys()
	assert 'strawberry' in playbook.pages.keys()
	assert 'errors' in playbook.pages.keys()
	assert 'intro' in playbook.pages.keys()
	assert playbook.pages.values().all(os.exists(it.path.path))

	// test files are scanned correctly
	assert playbook.files.len == 1
	assert 'banana' in playbook.files.keys()
	assert playbook.files.values().all(os.exists(it.path.path))

	assert playbook.errors.len == 0
}
