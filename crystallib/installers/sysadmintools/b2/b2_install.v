module b2

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.ui.console
import freeflowuniverse.crystallib.lang.python
// import os

@[params]
pub struct InstallArgs {
pub mut:
	reset bool
}

pub fn install(args_ InstallArgs) ! {
	mut args := args_

	if args.reset == false && osal.done_exists('install_b2') {
		return
	}

	console.print_header('install b2')

	mut py := python.new(name: 'default')! // a python env with name test
	py.update()!
	py.pip('b2')!

	osal.done_set('install_b2', 'OK')!

	return
}
