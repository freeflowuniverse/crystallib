module bizmodel

import os

fn test_scan() ! {
	p1 := '${os.dir(@FILE)}/example/params'
	p2 := '${os.dir(@FILE)}/example/wikisource'

	mut bm := new(
		name: 'test'
		path: p1
		mdbook_source: p2
	)!

	println(bm)
}
