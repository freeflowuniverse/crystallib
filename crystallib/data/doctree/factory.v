module doctree

// import freeflowuniverse.crystallib.osal
import freeflowuniverse.crystallib.core.texttools

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


	return &t
}

