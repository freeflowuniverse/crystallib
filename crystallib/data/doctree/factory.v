module doctree

import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.texttools

import log
import freeflowuniverse.crystallib.core.smartid

__global (
	knowledgetrees shared map[string]&Tree
)

@[params]
pub struct TreeArgsGet {
pub mut:
	name string = 'default'
	cid  string = '000'
}

pub fn tree_key(args_ TreeArgsGet) string {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	return '${args.cid}__${args.name}'
}

// get a new tree initialized, doesn't get remembered in global .
// will create a new tree instance .
//```
// name string = 'default'
// cid  string
//```	
// all arguments are optional
pub fn tree_create(args_ TreeArgsGet) !&Tree {
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

// get the tree out of memory .
// will create a new tree instance if it didn't exist yet.
//```
// name string = 'default'
// cid  string
//```	
// all arguments are optional
pub fn tree_get(args TreeArgsGet) !&Tree {
	key := tree_key(args)
	lock knowledgetrees {
		if key !in knowledgetrees {
			mut tree := tree_create(args)!
			knowledgetrees[key] = tree
		}
		return knowledgetrees[key] or { panic("can't find tree") }
	}
	return error('bug')
}
