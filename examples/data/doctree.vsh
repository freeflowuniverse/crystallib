#!/usr/bin/env -S v -w -cg -enable-globals run

import freeflowuniverse.crystallib.data.doctree
import os

testpath:="${os.home_dir()}/code/github/freeflowuniverse/crystallib/crystallib/data/doctree/testdata/collections/riverlov"

mut tree := doctree.new()!

tree.scan(path: testpath)!

// mut p := tree.page_get('riverlov:aboutus.md')!
// println(p)

tree.export(dest: '/tmp/remove')!
