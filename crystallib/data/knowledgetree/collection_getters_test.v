module knowledgetree

import os

const (
	testpath = os.dir(@FILE) + '/testdata/collections'
)

fn test_collection_get() {
	mut tree := knowledgetree.new()!
	tree.scan(
		path: testpath
		heal: false
	)!
	println('scanned test')
	c := tree.collection_get('examples')!
	assert c.name == 'examples'
	assert c.pages.keys().len > 0
}