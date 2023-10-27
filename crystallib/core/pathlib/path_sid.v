module pathlib

import freeflowuniverse.crystallib.baobab.smartid

// sids_acknowledge .
// means our redis server knows about the sid's found, so we know which ones to generate new
pub fn (mut path Path) sids_acknowledge(cid smartid.CID) ! {
	t := path.read()!
	cid.sids_acknowledge(t)!
}

// sids_replace .
// find parts of text in form sid:*** till sid:******  .
// replace all occurrences with new sid's which are unique .
// cid = is the circle id for which we find the id's .
// sids will be replaced in the files if they are different
pub fn (mut path Path) sids_replace(cid smartid.CID) ! {
	t := path.read()!
	t2 := cid.sids_replace(t)!
	if t2 != t {
		// means we have change and we need to write it
		path.write(t2)!
	}
}
