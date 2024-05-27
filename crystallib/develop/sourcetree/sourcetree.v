module sourcetree

import freeflowuniverse.crystallib.osal
import os
import freeflowuniverse.crystallib.ui.console

@[params]
pub struct OpenArgs {
pub mut:
	path string
}

// will look for git in location if not found will give error
// if not specified will use current dir
pub fn open(args OpenArgs) ! {
	if !os.exists(args.path) {
		return error('Cannot open SourceTree: could not find path ${args.path}')
	}
	cmd4 := 'open -a SourceTree ${args.path}'
	// console.print_debug(cmd4)
	osal.execute_interactive(cmd4)!
}
