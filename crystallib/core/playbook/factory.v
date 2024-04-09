module playbook

import freeflowuniverse.crystallib.core.base

@[params]
pub struct PlayBookNewArgs {
pub mut:
	path       string
	text       string
	git_url    string
	git_pull   bool
	git_branch string
	git_reset  bool
	prio       int  = 50
	execute    bool = true
	session    &base.Session
}

// get a new playbook, can scan a directory or just add text
// ```
// path string
// text string
// git_url string
// git_pull bool
// git_branch string
// git_reset bool
// execute bool = true
// session &base.Session
// ```
pub fn new(args_ PlayBookNewArgs) !PlayBook {
	mut args := args_
	mut plbook := PlayBook{
		session: args_.session
	}

	if args.path.len > 0 || args.text.len > 0 || args.git_url.len > 0 {
		plbook.add(
			path: args.path
			text: args.text
			git_url: args.git_url
			git_pull: args.git_pull
			git_branch: args.git_branch
			git_reset: args.git_reset
			prio: args.prio
			session: args.session
		)!
	}
	if args.execute {
		// plbook.execute()
		panic('not implemented')
	}
	return plbook
}
