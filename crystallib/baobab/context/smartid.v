module context

import freeflowuniverse.crystallib.baobab.smartid

@[params]
pub struct GIDNewArgs {
pub mut:
	gid_str  string // rid.cid.oid format
	oid_u32  u32
	oid_int  int
	oid_str  string // e.g. aaa, is 1...6 letter representation of a unique id
	cid_int  int    // int representation of cid
	cid_str  string // string representation of cid
	cid_name string // chosen name of circle
}

// smartid is of form region.circle.id .
// each part (also called smartid) min3 max 6 chars, each char = a...z or 0...9 .
///return global smartid .
// id empty then will generate unique one, circle needs to be specified if new one
// args .
// gid_str string // rid.cid.oid format
// id  string
// cid_str string //string representation of cid
// cid_name string //name representation of cid
// ```	
pub fn gid(args GIDNewArgs) !smartid.GID {
	mut gna := smartid.GIDNewArgs{
		...args
	}
	return smartid.gid(gna)!
}
