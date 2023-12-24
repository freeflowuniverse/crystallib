module playbook


@[params]
pub struct PlayBookNewArgs {
pub:
	path    string
	text    string
	// execute bool = true
}


// get a new playbook, can scan a directory or just add text
// ```
// path    string
// text    string
// ```
pub fn new(args PlayBookNewArgs)!PlayBook {

	mut plbook:=PlayBook{}

	if args.path.len>0 || args.text.len>0 {
		plbook.add(path:args.path,text:args.text)!
	}

	return plbook

}