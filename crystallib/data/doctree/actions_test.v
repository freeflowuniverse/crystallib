module doctree

import os

const collections_path = os.dir(@FILE) + '/testdata/collections'

fn test_actionscan() ! {
	mut tree := tree_create()!
	tree.scan(
		path: doctree.collections_path
		heal: false
	)!

	mut c := tree.collection_get('actions')!

	assert c.page_exists('actions1')
	assert c.page_exists('actions2')

	mut actions1_page := c.page_get('actions1')!
	d1 := actions1_page.doc(mut dest: actions1_page.path.parent()!.path)!
	mut a1 := d1.actions()
	assert a1.len == 1
	assert a1[0].actor == 'payment3'
	assert a1[0].name == 'add'

	mut actions2_page := c.page_get('actions2')!
	d2 := actions2_page.doc(mut dest: actions2_page.path.parent()!.path)!
	mut a2 := d2.actions()
	assert a2.len == 2
	assert a2[0].name == 'add'
	assert a2[1].name == 'add2'
}
