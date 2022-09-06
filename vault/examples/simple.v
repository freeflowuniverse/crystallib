module main

import freeflowuniverse.crystallib.vault
import os

const testdir2 = os.dir(@FILE) + '/../../pathlib/examples/test_path'

fn do() ? {
	mut v := vault.do(testdir2)?
	println(v)
}

fn main() {
	do() or { panic(err) }
}
