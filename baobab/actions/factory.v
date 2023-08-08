module actions

[params]
pub struct ActionParserArgs {
pub:
	text          string
	path          string // can be dir or file
	defaultdomain string = 'protocol_me'
	defaultcircle   string
	defaultactor  string
}

// get an actionparser and do the processing, can always add text and files later see actionparser.path_add and text_add
// it will sort the actions if filter is given and remove the ones which are in error or not belonging to book or actor
// params
// 		text:string
// 		path:string 		//can be dirpath or filepath
// 		domain_default  string = "protocol_me"
// 		actor_default  string
// 		book_default   string
pub fn new(args ActionParserArgs) !ActionsParser {
	mut ap := ActionsParser{}
	ap.defaultdomain = args.defaultdomain
	ap.defaultcircle = args.defaultcircle
	ap.defaultactor = args.defaultactor
	if args.text.len > 0 {
		ap.text_add(args.text)!
	}
	if args.path.len > 0 {
		ap.path_add(args.path)!
	}
	return ap
}

// TODO: needs to be debugged and tests checked
