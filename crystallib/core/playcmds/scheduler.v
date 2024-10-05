module playcmds

import freeflowuniverse.crystallib.installers.sysadmintools.daguserver

pub fn scheduler(heroscript string) ! {
	daguserver.play(
		heroscript: heroscript
	)!
}
