#!/usr/bin/env v -w -cg -enable-globals run

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.play
import freeflowuniverse.crystallib.core.playcmds
import freeflowuniverse.crystallib.installers.mdbook
import freeflowuniverse.crystallib.installers.restic
import freeflowuniverse.crystallib.installers.zola
import os

console.print_header('Install some tools')
mdbook.install()!
restic.install()!
zola.install()!


console.print_header("Some test with mdbook.")

mut session := play.session_new(
	context_name: "test"
	coderoot: "~/hero/var/mdbook_test"
	interactive: true
)!

//get code from git, will be found in ~/hero/var/mdbook_test
session.context.gitstructure.code_get(url: "https://github.com/freeflowuniverse/home")!


//get path local to the current script
path_my_actions := '${os.dir(@FILE)}/books_actions'
// path_my_actions:="/Users/despiegk1/code/github/freeflowuniverse/crystallib/examples/mdbook/books_actions/sshkey.md"

// //add all actions inside to the playbook
session.playbook_add(path:path_my_actions)!
session.process()!

println(session.plbook)

// //run all the actions known
playcmds.run(mut session)!

