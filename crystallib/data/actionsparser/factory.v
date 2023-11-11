module actionsparser

import freeflowuniverse.crystallib.baobab.smartid
import freeflowuniverse.crystallib.core.texttools

[params]
pub struct ParserArgs {
pub:
	text               string
	path               string // can be dir or file
	default_cid        u32
	default_cid_string string
	default_cid_name   string
	defaultactor       string
	readwrite          bool
}

// get an actionparser and do the processing, can always add text and files later see actionparser.path_add and text_add .
// it will sort the parser if filter is given and remove the ones which are in error or not belonging to circle or actor .
// params .
// ```
// text          string
// path          string // can be dir or file
// default_cid u32
// default_cid_string  string
// default_cid_name string
// defaultactor  string
// ```
pub fn new(args ParserArgs) !Parser {
	mut parser := Parser{}

	parser.defaultactor = texttools.name_fix(args.defaultactor)
	cid := smartid.cid(
		name: args.default_cid_name
		cid_int: args.default_cid
		cid_string: args.default_cid_string
	)!
	parser.default_cid = cid
	if args.text.len > 0 {
		parser.add(text: args.text, readwrite: args.readwrite, cid: cid)!
	}
	if args.path.len > 0 {
		parser.add(path: args.path, readwrite: args.readwrite, cid: cid)!
	}
	return parser
}
