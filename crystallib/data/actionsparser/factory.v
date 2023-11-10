module actionsparser

[params]
pub struct ActionsArgs {
pub:
	text          string
	path          string // can be dir or file
	defaultcircle string 
	defaultactor  string
	actor_filter []string
	action_filter []string
}

// get an actionparser and do the processing, can always add text and files later see actionparser.path_add and text_add .
// it will sort the actions if filter is given and remove the ones which are in error or not belonging to circle or actor .
// params .
// ```
// 		text:string
// 		path:string 		//can be dirpath or filepath
// 		cid_default  string = "core"
// 		actor_default  string
// 		circle_default   string
// ```
pub fn new(args ActionsArgs) !Actions {
	mut ap := Actions{}
	ap.defaultcid = args.defaultcid
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



// get an actionparser and do the processing, can always add text and files later see actionparser.path_add and text_add .
// it will sort the actions if filter is given and remove the ones which are in error or not belonging to circle or actor .
// params .
// ```
// 		text:string
// 		path:string 		//can be dirpath or filepath
// 		cid_default  string = "core"
// 		actor_default  string
// 		circle_default   string
// ```
pub fn get(args ActionsArgs) ![]Action {
	mut ap := Actions{}
	ap.defaultcid = args.defaultcid
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
