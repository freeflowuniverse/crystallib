module actionsparser

[params]
pub struct ActionParserArgs {
pub:
	text   string
	path   string   // can be dir or file
	filter []string // how to sort & filter
	actor  string
	book   string
}

// get an actionparser and do the processing, can always add text and files later see actionparser.path_add and text_add
// it will sort the actions if filter is given and remove the ones which are in error or not belonging to book or actor
// params
// 		text:string
// 		path:string 		//can be dirpath or filepath
// 		filter:[]string 	//how to sort & filter
// 		actor:string
// 		book:string
pub fn new(args ActionParserArgs) !ActionsParser {
	mut ap := ActionsParser{
		filter: args.filter
		actor: args.actor
		book: args.book
	}
	if args.text.len > 0 {
		ap.text_add(args.text)!
	}
	if args.path.len > 0 {
		ap.path_add(args.path)!
	}
	return ap
}
