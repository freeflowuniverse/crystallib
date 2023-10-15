module main

import freeflowuniverse.crystallib.osal.gittools


fn do() ! {
	coderoot:='/tmp/code_test'
	mut gs := gittools.get(coderoot: coderoot)!

	println(gs)

	mut path := gittools.code_get(
		coderoot:coderoot
		url: 'https://github.com/despiegk/ourworld_data'
	)!

	println(path)
	// this will show the exact path of the manual
}

fn main() {
	do() or { panic(err) }
}
