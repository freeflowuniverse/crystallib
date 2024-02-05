#!/usr/bin/env v -w -cg -enable-globals run

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.core.playbook
import freeflowuniverse.crystallib.core.playcmds
import freeflowuniverse.crystallib.installers.web.mdbook as mdbookinstaller
import os


console.print_header('Lets use a 3script to generate an mdbook')
mdbookinstaller.install()!


//will create session and run a playbook from a 3script

mut session := play.session_new(
	context_name: "test"
	interactive: true
	url:"https://git.ourworld.tf/threefold_coop/info_threefold_coop/src/branch/main/script3"
	run:true
)!

//now run them for the generic and understood playcmds
playcmds.run(session)!
