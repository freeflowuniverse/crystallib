module doctree

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools

@[params]
pub struct CollectionNewArgs {
mut:
	name string @[required]
	path string @[required]
	heal bool // healing means we fix images, if selected will automatically load, remove stale links
	load bool = true
}

// get a new playbook
pub fn (mut tree Tree) playbook_new(args_ CollectionNewArgs) !&Collection {
	mut args := args_
	args.name = texttools.name_fix(args.name)

	if args.name in tree.playbooks {
		return error('Collection already exits')
	}

	mut pp := pathlib.get_dir(path: args.path)! // will raise error if path doesn't exist
	mut playbook := &Collection{
		name: args.name
		tree: tree
		path: pp
		heal: args.heal
	}
	if args.load {
		playbook.scan()!
	}

	tree.playbooks[playbook.name] = playbook
	return playbook
}
