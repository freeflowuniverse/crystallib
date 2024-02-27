module doctree

import os

const mydata_path = os.dir(@FILE) + '/testdata/collections'

fn test_scan_internal() ! {
	mut tree := new()!

	tree.scan(path: doctree.mydata_path)!

	mut p := tree.page_get('riverlov:aboutus.md')!

	tree.export(dest: '/tmp/remove')!

	// if true{panic("ooo")}
}
