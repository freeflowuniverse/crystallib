module smartid

// import math
// import rand

// global smart if, represents an object on global level
pub struct GID {
pub mut:
	cid CID
mut:
	region u32
	id     u32
}

[params]
pub struct GIDNewArgs {
pub mut:
	gid_str  string // rid.cid.oid format
	oid_int  int
	oid_str  string // e.g. aaa, is 1...6 letter representation of a unique id
	cid_int  int    // int representation of cid
	cid_str  string // string representation of cid
	cid_name string // chosen name of circle
}

// get global unique id .
// params: .
// ```
// gid_str  string // rid.cid.oid format
// oid_int  int
// oid_str  string // e.g. aaa, is 1...6 letter representation of a unique id
// cid_int  int    // int representation of cid
// cid_str  string // string representation of cid
// cid_name string // chosen name of circle
// ```
pub fn gid(args_ GIDNewArgs) !GID {
	mut args := args_

	mut o := GID{}
	if args.gid_str.len > 0 {
		if args.oid_int > 0 || args.cid_int > 0 || args.oid_str.len > 0 || args.cid_str.len > 0
			|| args.cid_name.len > 0 {
			return error('if gid_str used cannot use any of the other properties')
		}

		gid := args.gid_str
		mut ids := gid.split('.')
		if ids.len > 3 {
			return error('need format d.d.d max 2 . for a global smartid \n${gid}')
		}
		mut r := []u32{}
		for id in ids {
			if id.len > 6 || id.len < 2 {
				return error('one of the parts is too small or too large, needs to be 2...5 \n${gid}')
			}
			for cha in id {
				if (cha < 48 || cha > 57) && (cha < 97 || cha > 122) {
					return error('each char needs to be: a.z, 0.9. \n${gid}')
				}
			}
			r << sid_int(id)
		}
		if r.len == 2 {
			o.region = r[0]
			o.cid = cid(cid_int: r[1])!
			o.id = r[2]
		} else if r.len == 1 {
			o.cid = cid(cid_int: r[0])!
			o.id = r[1]
		} else if r.len == 0 {
			o.id = r[0]
		} else {
			return error('gsmartid string not properly constructed.\n${gid}')
		}
		return o
	}
	if args.cid_int == 0 && args.cid_str.len == 0 && args.cid_name.len == 0 {
		return error('need to specify cid_int, cid_str or cid_name')
	}

	o.cid = cid(cid_int: u32(args.cid_int), cid_string: args.cid_str, name: args.cid_name)!

	if args.oid_int > 0 && args.oid_str.len > 0 {
		return error('cannot specify oid_int and oid_str')
	}
	if args.oid_str.len > 0 {
		args.oid_int = sid_int(args.oid_str)
	}
	o.id = u32(args.oid_int)
	if o.id == 0 {
		id_string := sid_new(o.cid.str())!
		o.id = sid_int(id_string)
	}
	return o
}

// check if format is [..5].[..5].[..5] . and [..5] is string
// return error if issue
pub fn gid_check(gid string) bool {
	mut ids := gid.split('.')
	if ids.len > 3 {
		return false
	}
	for id in ids {
		if id.len > 6 || id.len < 2 {
			return false
		}
		for cha in id {
			if (cha < 48 || cha > 57) && (cha < 97 || cha > 122) {
				return false
			}
		}
	}
	return true
}

// raise error if smartid not valid
pub fn gid_test(gid string) ! {
	if !gid_check(gid) {
		return error('gid:${gid} is not valid.')
	}
}

// fn (gid GID) check() !{
// 	if gid.id == 0{
// 		return error("gid cannot be 0.\n$gid")
// 	}
// 	if gid.circle == 0{
// 		return error("circle cannot be 0.\n$gid")
// 	}
// }

// object id in u32
pub fn (gid GID) oid() u32 {
	return gid.id
}

// object id as string
pub fn (gid GID) ostr() string {
	return sid_str(gid.id)
}

// object id as string
pub fn (gid GID) str() string {
	return '${gid.cid.str()}.${gid.ostr()}'
}
