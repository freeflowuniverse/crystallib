module doctree

import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.paramsparser
import os

const collections_path = os.dir(@FILE) + '/testdata/collections'

fn test_actionscan() ! {
	mut tree := new()!
	tree.scan(
		path: doctree.collections_path
		heal: false
	)!

	mut c := tree.collection_get('actions')!

	assert c.page_exists('actions1')
	assert c.page_exists('actions2')

	if d1 := c.page_get('actions1')!.doc {
		mut a1 := d1.actions()
		assert a1.len == 1
		assert a1[0].actor == 'payment3'
		assert a1[0].name == 'add'
	} else {
		assert false, 'doc for page actions1 is missing'
	}

	if d2 := c.page_get('actions2')!.doc {
		mut a2 := d2.actions()
		assert a2.len == 2
		assert a2[0].name == 'add'
		assert a2[1].name == 'add2'
	} else {
		assert false, 'doc for page actions2 is missing'
	}
}
