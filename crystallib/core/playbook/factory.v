module playbook
import freeflowuniverse.crystallib.osal.gittools
@[params]
pub struct PlayBookNewArgs {
pub:
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
pub fn new(args PlayBookNewArgs) !PlayBook {
	mut plbook := PlayBook{}
	mut gs := gittools.get()!
	mut repo := gs.repo_get_from_url(url: args.url)?
	args.path = repo.path_content_get()
	if args.path.len > 0 || args.text.len > 0 {
		plbook.add(path: args.path, text: args.text)!
	}
	return plbook
}
