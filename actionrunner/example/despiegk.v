module main

import os.cmdline
// import os
import freeflowuniverse.crystallib.actionrunner
import os

fn do() ! {
	// will look for
	// export RUNNERDOC=https://gist.github.com/despiegk/linknotspecified
	// if the env argument found will get the code and execute
	actionrunner.run_env()!
}

fn main() {
	do() or { panic(err) }
}
