module actionsparser

import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.core.texttools

[params]
pub struct ActionsArgs {
pub:
	text               string
	path               string // can be dir or file
	default_cid_int    u32
	default_cid_string string
	default_cid_name   string
	defaultactor       string
}

// get an actionparser and do the processing, can always add text and files later see actionparser.path_add and text_add .
// it will sort the actions if filter is given and remove the ones which are in error or not belonging to circle or actor .
// params .
// ```
// text          string
// path          string // can be dir or file
// default_cid_int u32
// default_cid_string  string
// default_cid_name string
// defaultactor  string
// ```
pub fn new(args ActionsArgs) !Actions {
	mut actions := Actions{}

	actions.defaultactor = texttools.name_fix(args.defaultactor)
	cid := smartid.cid(
		name: args.default_cid_name
		cid_int: args.default_cid_int
		cid_string: args.default_cid_string
	)!
	actions.default_cid_int = cid
	if args.text.len > 0 {
		actions.text_add(args.text)!
	}
	if args.path.len > 0 {
		actions.path_add(args.path)!
	}
	return actions
}
