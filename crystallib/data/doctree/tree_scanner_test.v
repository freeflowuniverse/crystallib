module doctree

import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.paramsparser
import os

const playbooks_path = os.dir(@FILE) + '/testdata/playbooks'
const tree_name = 'mdbook_test_tree'
const book1_path = os.dir(@FILE) + '/testdata/book1'
// const book1_dest = os.dir(@FILE) + '/testdata/_book1'

fn test_scan() ! {
	mut tree := tree_create()!
	tree.scan(
		path: doctree.playbooks_path
		heal: false
	)!

	mut c := tree.playbook_get('rpc')!

	pages := ['rpc', 'eth', 'stellar', 'tfchain']
	for page in pages {
		assert c.page_exists(page)
	}

	assert c.page_exists('rpc')
	assert c.page_exists('grant3') == false

	mut page := c.page_get('rpc')!

	mut c2 := tree.playbook_get('fruits')!

	assert c2.image_exists('digital_twin')
	mut i := c2.image_get('digital_twin')!
	println(i)
}
