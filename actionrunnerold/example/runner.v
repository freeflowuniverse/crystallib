module main

import os.cmdline
// import os
import freeflowuniverse.crystallib.actionrunner
import os

fn do() ! {
	options := cmdline.only_non_options(os.args)
	if options.len == 1 {
		if os.exists('run.md') {
			actionrunner.run_file('default', 'run.md')!
		}
		exit(0)
	}

	if options.len != 2 {
		// println(options)
		return error(' ERROR: please specify the path of the markdown actions file to start from')
	}

	if !os.exists(options[1]) {
		return error(" ERROR: could not find path for the input actions file (md): '${options[1]}'")
	}

	actionrunner.run_file('default', options[1])!
}

fn main() {
	do() or { panic(err) }
}
