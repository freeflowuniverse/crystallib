module doctreeold

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.core.play
import log

@[params]
pub struct TreeNewArgs {
pub mut:
	context ?play.Context
}


// get a new tree initialized, doesn't get remembered in global .
// will create a new tree instance .
//```
// name string = 'default'
// cid  string
//```	
// all arguments are optional
pub fn new(args_ TreeArgsGet) !&Tree {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	level := match osal.env_get_default('KNOWLEDGETREE_LOG_LEVEL', 'INFO') {
		'DEBUG' {
			log.Level.debug
		}
		else {
			log.Level.info
		}
	}
	mut t := Tree{
		name: args.name
		logger: &log.Log{
			level: level
		}
		cid: args.cid
	}
	return &t
}
