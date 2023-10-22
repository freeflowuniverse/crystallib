module smartid

import freeflowuniverse.crystallib.core.pathlib
import freeflowuniverse.crystallib.core.texttools.regext

[params]
struct LoadArgs {
pub mut:
	path    string
	content string
	cid     string
}

// load from a textfile, find all smart id's
pub fn load(args_ LoadArgs) ! {
	mut args := args_
	if args.path.len > 0 {
		mut p := pathlib.get_file(args.path, false)!
		args.content = p.read()!
	}
	sids_set(args.content, args.cid)!
}

// set the sids in redis, so we remember them all, and we know which one is the latest
fn sids_set(text string, cid string) ! {
	res := regext.find_sid(text)
	for sid in res {
		sid_aknowledge(sid, cid)!
	}
}
