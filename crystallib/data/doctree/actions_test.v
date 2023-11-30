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

	mut page := c.page_get('actions1')!

	println(page.doc)

	mut d1 := page.doc or { panic("doc doesn't exist") }
	mut d2 := page.doc or { panic("doc doesn't exist") }

	mut md1 := d1.markdown()
	println(md1)

	mut a1 := d1.actions()
	println(a1)

	mut a2 := d2.actions()
	println(a2)

	if true {
		panic('iii')
	}
}
