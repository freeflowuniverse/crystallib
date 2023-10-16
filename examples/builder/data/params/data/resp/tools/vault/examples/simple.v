module main

import freeflowuniverse.crystallib.vault
import freeflowuniverse.crystallib.pathlib
import os

const testdir2 = os.dir(@FILE) + '/easy'

fn do() ? {
	mut v := vault.do(testdir2)?

	remember := v.hash()

	mut p := pathlib.get('${testdir2}/subdir/subsudir/test3.md')
	p.write('5')?
	mut v2 := vault.do(testdir2)? // will remember the change
	p.write('a')?
	mut v3 := vault.do(testdir2)? // will remember the change

	println(v3.superlist())
	println(v3.hash())

	// restore to the original scan
	mut v4 := vault.restore(0)?
	remember3 := v.hash()
	assert remember == remember3

	v3.delete()?
}

fn main() {
	do() or { panic(err) }
}
