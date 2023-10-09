module bizmodel

import freeflowuniverse.crystallib.data.knowledgetree
import os

fn test_scan() ! {
	knowledgetree.new(name: 'test_tree')!
	knowledgetree.scan(
		name: 'test_tree'
		path: '${os.dir(@FILE)}/example/wiki'
		heal: true
	)!
	rlock knowledgetrees {
		println(knowledgetrees)
	}
	panic('sh')
}
