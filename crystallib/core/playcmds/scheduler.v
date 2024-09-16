module playcmds

import freeflowuniverse.crystallib.installers.sysadmintools.daguserver

pub fn scheduler(heroscript string) ! {
	mut dserver := daguserver.get()!

	// mut dagucl:=dserver.client()!

	println(heroscript)
	if true {
		panic('s')
	}
}
