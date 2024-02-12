module doctree

import os

const mydata_path = os.dir(@FILE) + '/testdata/collections'

fn test_scan_internal() ! {
	mut tree := tree_create()!

	tree.scan(path: doctree.mydata_path)!

	mut p := tree.page_get('riverlov:aboutus.md')!

	// mut p:=tree.page_get("riverlov:introduction.md")!

	// heal_export bool = true
	// heal_source bool
	// dest        string // if we want to relocate images for links
	// c1:=p.doc(mut heal_export:true)!

	tree.export(dest: '/tmp/remove')!

	// println(c1)
	// println(c1.markdown())

	// if true{
	// 	panic("s")
	// }

	// TODO: need to do some tests, in how it need to looks like, check files & images are there in /tmp/remove

	// TODO: remove test dir
}
