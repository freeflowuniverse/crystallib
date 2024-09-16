module doctree

// import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.texttools

__global (
	doctrees shared map[string]&Tree
)

@[params]
pub struct TreeArgsGet {
pub mut:
	name string = 'default'
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
	mut t := Tree{
		name: args.name
	}
	tree_set(t)
	return &t
}

// get sheet from global
pub fn tree_get(name string) !&Tree {
	rlock doctrees {
		if name in doctrees {
			return doctrees[name]
		}
	}
	return error("cann't doctree:'${name}'")
}

// remember sheet in global
pub fn tree_set(tree Tree) {
	lock doctrees {
		doctrees[tree.name] = &tree
	}
}
