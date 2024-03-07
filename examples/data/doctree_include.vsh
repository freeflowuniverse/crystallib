#!/usr/bin/env -S v -w -cg -enable-globals run

import freeflowuniverse.crystallib.data.doctree
import freeflowuniverse.crystallib.webtools.mdbook
import os

collections_path := '${os.home_dir()}/code/github/freeflowuniverse/crystallib/crystallib/data/doctree/testdata/includetest/'

mut tree := doctree.new(name: 'test')!
tree.scan(
	path: collections_path
	heal: false
)!

assert tree.collections.len == 3

// println(tree.collections.keys())
assert tree.collections.keys() == ['riverlov', 'server', 'sub2']

dest := '/tmp/mdbooktest'
tree.export(dest: '${dest}/tree', reset: true)!
mut mdb := mdbook.get(instance: 'mdbooktest')!

// mut cfg := mdbooks.config()!
// cfg.path_build = buildroot
// cfg.path_publish = publishroot

mut b:=mdb.generate(
	doctree_path: '${dest}/tree'
	name: 'includetest'
	title: 'Incude Test'
	summary_path: '${os.home_dir()}/code/github/freeflowuniverse/crystallib/crystallib/data/doctree/testdata/includetest/summary.md'
	summary_url: '' // because path given
	publish_path: '${dest}/publish'
	build_path: '${dest}/build'
)!

b.open()!