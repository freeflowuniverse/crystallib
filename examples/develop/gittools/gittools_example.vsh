#!/usr/bin/env -S v -gc none -no-retry-compilation -cc tcc -d use_openssl -enable-globals run

import freeflowuniverse.crystallib.develop.gittools2 as gittools

// resets all for all git configs & caches
// gittools.reset()!

mut gs_default := gittools.get()!

gs_default.list()!
// println(gs_default)

// coderoot := '/tmp/code_test'
// mut gs := gittools.get(coderoot: coderoot)!

// // println(gs)

// mut path := gittools.code_get(
// 	coderoot: coderoot
// 	url:      'https://github.com/despiegk/ourworld_data'
// )!

// gs_default.list()!
// gs.list()!

// println(path)
// this will show the exact path of the manual
