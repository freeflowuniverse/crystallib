module main

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.vault
import os

const testdir = os.dir(@FILE) + '/../../pathlib/examples/test_path'

fn do() ? {
	// just to check it exists
	mut p := pathlib.get_dir(testdir, false)?
	p.absolute()
	println(p)
	// will load the vault, doesn't process files yet
	// mut vault1 := vault.scan('myvault', mut p)?
	// println(vault)
	// vault1.delete()?	
	mut vault2 := vault.scan('myvault', mut p)?
	vault2.shelve()?
	// println(vault2)
	vault2.delete()?
}

fn main() {
	do() or { panic(err) }
}
