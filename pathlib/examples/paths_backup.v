module main

import freeflowuniverse.crystallib.pathlib
import params
import os

const testpath = os.dir(@FILE) + '/test_path/test_parent/readme.md'
const testdir = os.dir(@FILE) + '/test_path'


fn do() ? {
	mut p := pathlib.get_file(testpath, false)?

	p1 := p.backup()?
	p2 := p.backup()?
	// p3 := p.write_backup("d ")?
	println(p1)
	println(p2)
	// println(p3)

	// p.backup()?
	// p.backup()?

	mut premove := pathlib.get_dir(testdir, false)?
	premove.backups_remove()?
}

fn main() {
	do() or { panic(err) }
}
