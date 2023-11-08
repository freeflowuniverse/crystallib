module smartid

pub struct CID {
pub mut:
	circle u32
}

[params]
pub struct CIDGet {
pub mut:
	name       string
	cid_int    u32
	cid_string string
}

// get a circle id .
// circle's are unique per twin .
// params: .
// ```
// name       string
// cid_int    u32
// cid_string string
// ```
// returns circle ..
// ```
// struct CID {
// 		circle u32
// }
// ```
pub fn cid(args_ CIDGet) !CID {
	mut args:=args_
	if args.cid_int > 0 {
		return CID{
			circle: args.cid_int
		}
	} else if args.cid_string.len > 0 {
		return CID{
			circle: sid_int(args.cid_string)
		}
	} else if args.name.len > 0 {
		return cid_from_name(args.name)!
	} else {
		return error('need to specify name, cid_int or cid_string')
	}
	panic('bug')
}

// this is the cid for circle0
pub fn cid_core() CID {
	mut cid := CID{
		circle: 0
	}
	return cid
}

pub fn (cid CID) u32() u32 {
	return cid.circle
}

pub fn (cid CID) str() string {
	return sid_str(cid.circle)
}

pub fn (cid CID) name() !string {
	if cid.circle == 1 {
		return 'core'
	}
	return name_from_u32(cid.circle)
}

[params]
pub struct OIDGetArgs {
pub mut:
	oid_int int    // int representation of cid
	oid_str string // string representation of cid
}

pub fn (cid CID) gid(args OIDGetArgs) !GID {
	return gid(cid_str: cid.str(), oid_int: args.oid_int, oid_str: args.oid_str)
}

pub fn (cid CID) sids_replace(txt string) !string {
	return sids_replace(cid.str(), txt)!
}

pub fn (cid CID) sids_acknowledge(txt string) ! {
	sids_acknowledge(cid.str(), txt)!
}
