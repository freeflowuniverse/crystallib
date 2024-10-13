module doctree3

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools
import freeflowuniverse.crystallib.data.doctree3.collection

@[params]
pub struct CollectionNewArgs {
mut:
	name string @[required]
	path string @[required]
	heal bool = true // healing means we fix images, if selected will automatically load, remove stale links
	load bool = true
}

// get a new collection
pub fn (mut tree Tree) new_collection(args_ CollectionNewArgs) !&collection.Collection {
	mut args := args_
	args.name = texttools.name_fix(args.name)

	if args.name in tree.collections {
		return error('Collection with name ${args.name} already exits')
	}

	mut pp := pathlib.get_dir(path: args.path)! // will raise error if path doesn't exist
	mut new_collection := &collection.Collection{
		name: args.name
		// tree: tree
		path: pp
		heal: args.heal
	}
	if args.load {
		new_collection.scan()!
	}

	tree.collections[new_collection.name] = new_collection
	return new_collection
}
