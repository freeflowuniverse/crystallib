module doctree3

import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.doctree3.collection
import freeflowuniverse.crystallib.data.doctree3.collection.page
import freeflowuniverse.crystallib.core.texttools.regext

__global (
	doctrees shared map[string]&Tree
)

pub enum TreeState {
	init
	ok
	error
}

@[heap]
pub struct Tree {
pub:
	name string
pub mut:
	collections map[string]&collection.Collection
	defs        map[string]&page.Page // TODO: what are defs?
	state       TreeState
	// context context.Context
	cid      string = '000'
	replacer ?regext.ReplaceInstructions // TODO: what is replacer?
}

// the unique key to remember a tree .
// is unique per circle (based on cid)
pub fn (tree Tree) key() string {
	return '${tree.cid}__${tree.name}'
}

@[params]
pub struct TreeArgsGet {
pub mut:
	name string = 'default'
}

// new creates a new tree and stores it in global map
pub fn new(args_ TreeArgsGet) !&Tree {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	mut t := Tree{
		name: args.name
	}
	tree_set(t)
	return &t
}

// tree_get gets tree from global map
pub fn tree_get(name string) !&Tree {
	rlock doctrees {
		if name in doctrees {
			return doctrees[name]
		}
	}
	return error("cann't doctree:'${name}'")
}

// tree_set stores tree in global map
pub fn tree_set(tree Tree) {
	lock doctrees {
		doctrees[tree.name] = &tree
	}
}
