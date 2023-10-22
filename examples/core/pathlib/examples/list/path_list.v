module main

import freeflowuniverse.crystallib.core.pathlib
import os

const testpath3 =  os.dir(@FILE)+"/../../.."

fn do() ! {
	mut p := pathlib.get_dir(testpath3, false)!
	//IMPORTANT TO HAVE r'...   the r in front
	l:=p.list(regex:[r'.*\.v$'])!
	println(l)
}

fn main() {
	do() or { panic(err) }
}
