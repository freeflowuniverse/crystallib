module sourcetree

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.osal.gittools
import os

@[params]
pub struct OpenArgs {
pub mut:
	path string
}

//will look for git in location if not found will give error
//if not specified will use current dir
pub fn open(args OpenArgs){
	if args.path==""{
		args.path=gittools.git_dir_get()!
	}
	cmd4 := 'open -a SourceTree ${args.path}'
	// println(cmd4)
	osal.execute_interactive(cmd4)!
}

