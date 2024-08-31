module playcmds

import freeflowuniverse.crystallib.servers.daguserver

pub fn scheduler(heroscript string) ! {

	mut dserver:=daguserver.new()! 

	mut dagucl:=dserver.client()!



	println(heroscript)
	if true{
		panic("s")
	}

}