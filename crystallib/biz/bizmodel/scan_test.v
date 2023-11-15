module bizmodel

import freeflowuniverse.crystallib.data.doctree
import os

fn test_scan() ! {
	doctree.new(name: 'test_tree')!
	doctree.scan(
		name: 'test_tree'
		path: '${os.dir(@FILE)}/example/wiki'
		heal: true
	)!
	rlock knowledgetrees {
		println(knowledgetrees)
	}
	panic('sh')
}
