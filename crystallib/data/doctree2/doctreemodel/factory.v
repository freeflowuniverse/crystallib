module server

// import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.texttools

__global (
	doctree2 shared map[string]&DocTree
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
pub fn tree_new(args_ TreeArgsGet) !&DocTree {
	mut args := args_
	args.name = texttools.name_fix(args.name)
	mut t := DocTree{
		name: args.name
	}
	tree_set(t)
	return &t
}

// get sheet from global
pub fn tree_get(name string) !&DocTree {
	rlock doctree_server {
		if name in doctree2 {
			return doctree2[name]
		}
	}
	return error("cann't doctree:'${name}'")
}

// remember sheet in global
pub fn tree_set(tree DocTree) {
	lock doctree2 {
		doctree2[tree.name] = &tree
	}
}
