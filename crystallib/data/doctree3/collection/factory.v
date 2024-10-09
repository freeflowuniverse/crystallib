module collection

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools

pub enum CollectionState {
	init
	initdone
	scanned
	fixed
	ok
}

@[heap]
pub struct Collection {
pub:
	name string
pub mut:
	title  string
	pages  map[string]&Page // markdown pages in collection
	files  map[string]&File
	images map[string]&File
	path   pathlib.Path
	errors []CollectionError
	state  CollectionState
	// tree   &Tree             @[str: skip]
	heal bool = true
}

@[params]
pub struct CollectionNewArgs {
mut:
	name string @[required]
	path string @[required]
	heal bool = true // healing means we fix images, if selected will automatically load, remove stale links
	load bool = true
}

// get a new collection
pub fn new(args_ CollectionNewArgs) !Collection {
	mut args := args_
	args.name = texttools.name_fix(args.name)

	// if args.name in tree.collections {
	// 	return error('Collection already exits')
	// }

	mut pp := pathlib.get_dir(path: args.path)! // will raise error if path doesn't exist
	mut collection := Collection{
		name: args.name
		// tree: tree
		path: pp
		heal: args.heal
	}
	if args.load {
		collection.scan()!
	}

	return collection
}
