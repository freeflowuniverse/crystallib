module knowledgetree

import freeflowuniverse.crystallib.osal.gittools
import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.data.params
import os

const (
	collections_path = os.dir(@FILE) + '/testdata/collections'
	tree_name        = 'mdbook_test_tree'
	book1_path       = os.dir(@FILE) + '/testdata/book1'
	book1_dest       = os.dir(@FILE) + '/testdata/_book1'
)

fn test_scan() ! {
	new(name: knowledgetree.tree_name)!
	scan(
		name: knowledgetree.tree_name
		path: knowledgetree.collections_path
	)!
	rlock knowledgetrees {
		tree := knowledgetrees[knowledgetree.tree_name]

		// QUESTION: upon scan, should all folders be added as collection
		// or only ones with .collection / .site file?
		assert tree.collections.keys() == ['examples', 'fruits', 'playground', 'rpc', 'server',
			'vegetables']
	}
}
