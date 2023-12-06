module bizmodel

import freeflowuniverse.crystallib.data.doctree
import os

fn test_scan() ! {
	mut tree := doctree.new(name: 'test_tree')!
	tree.scan(
		name: 'test_tree'
		path: '${os.dir(@FILE)}/example/wiki'
		heal: true
	)!
	rlock knowledgetrees {
		println(knowledgetrees)
	}
}
