module doctree

import freeflowuniverse.crystallib.webtools.mdbook
import os
import freeflowuniverse.crystallib.ui.console

const collections_path = os.dir(@FILE) + '/testdata/includetest'

fn test_page_get() {
	mut tree := new(name: 'test')!
	tree.scan(
		path: doctree.collections_path
		heal: false
	)!

	assert tree.collections.len == 3

	// console.print_debug(tree.collections.keys())
	assert tree.collections.keys() == ['riverlov', 'server', 'sub2']

	dest := '/tmp/mdbooktest'
	tree.export(dest: '${dest}/tree', reset: true)!

	// mut mdb := mdbook.get(instance: "mdbooktest")!

	// // mut cfg := mdbooks.config()!
	// // cfg.path_build = buildroot
	// // cfg.path_publish = publishroot

	// mdb.generate(
	// 	doctree_path: "${dest}/tree"
	// 	name: "includetest"
	// 	title: "Incude Test"
	// 	summary_path: doctree.collections_path
	// 	summary_url: '' //because path given
	// 	publish_path: "${dest}/publish"
	// 	build_path: "${dest}/build"		
	// )!	

	// if true {
	// 	panic('fghjkjhgfghjk')
	// }
}
