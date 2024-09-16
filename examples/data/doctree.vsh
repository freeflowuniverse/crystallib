#!/usr/bin/env -S v -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.data.doctree
import os

testpath := '${os.home_dir()}/code/github/freeflowuniverse/crystallib/crystallib/data/doctree/testdata/collections/'

mut tree := doctree.new()!

tree.scan(path: testpath)!

tree.process_defs()! // process includes
tree.process_includes()! // process includes

mut p := tree.page_get('riverlov:introduction.md')!
// println(p)
// mut mydoc := p.doc()!
// println(mydoc)

mut p2 := tree.page_get('riverlov:aboutus.md')!
mut mydoc2 := p2.doc()!
// // println(mydoc2.defpointers())	
// println(mydoc2)
println(mydoc2.markdown()!)

// tree.export(dest: '/tmp/remove')!
