#!/usr/bin/env v -w -cg -enable-globals run

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.core.playcmds
import os

console.print_header("Some test with zola.")

mut session := play.session_new(
	context_name: "test"
	interactive: true
)!

//get path local to the current script
path_my_actions := '${os.dir(@FILE)}/zola_actions'

// //add all actions inside to the playbook
session.playbook_add(path:path_my_actions)!
session.process()!
playcmds.run(mut session)!

