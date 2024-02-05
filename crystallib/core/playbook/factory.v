module playbook

import freeflowuniverse.crystallib.osal.gittools

@[params]
pub struct PlayBookNewArgs {
pub mut:
	path string
	text string
	url  string
	// execute bool = true
}

// get a new playbook, can scan a directory or just add text
// ```
// path    string
// text    string
// url  string
// ```
pub fn new(args_ PlayBookNewArgs) !PlayBook {
	mut args:=args_
	mut plbook := PlayBook{}
	// mut gs := gittools.get()!
	if args.url.len>0{
		mut repo := gittools.repo_get(url: args.url)!
		args.path = repo.addr.path()!.path
	}
	if args.path.len > 0 || args.text.len > 0 {
		plbook.add(path: args.path, text: args.text)!
	}
	return plbook
}
