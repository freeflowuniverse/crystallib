#!/usr/bin/env v -w -cg -enable-globals run

// import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.core.play
import os

console.print_header("Some test with mdbook.")

coderoot:="~/hero/var/mdbook_test"

mut session := play.session_new(
	context_name: "my_mdbook_test"
	coderoot: coderoot
	interactive: true
)!

//get code from git, will be found in ~/hero/var/mdbook_test
session.context.gitstructure.code_get(url: "https://github.com/freeflowuniverse/home")!


//get path local to the current script
path_my_actions := '${os.dir(@FILE)}/books_actions/'

//add all actions inside to the playbook
session.plbook.add(path:path_my_actions)!

//run all the actions
session.plbook.run() 

