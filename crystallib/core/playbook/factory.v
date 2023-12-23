module playbook

// get a new playbook, can scan a directory or just add text
// ```
// path    string
// text    string
// execute bool = true
// ```
pub fn new(args ParserArgs)!PlayBook {

	mut plbook:=PlayBook{}

	if args.path.len>0 || args.text.len>0 {
		plbook.add(path:args.path,text:args.text,execute:args.execute)!
	}

	return plbook

}