module smartid

// import math
// import rand

// global smart if, represents an object on global level
pub struct GlobalId {
pub mut:
	region u32
	circle u32
	obj    u32
}

[params]
pub struct GlobalIdNewArgs {
pub mut:
	gid_str   string // rid.cid.oid format
	gid_coord []int  // 3 coordinates first one is region
	cid       string 
	rid       string // can be empty
}

// TODO: tyes, coimur, needs to be implemented, needs to support txt or coordinates, and then use sid_new for getting new sid

// smartid is of form region.circle.obj .
// each part (also called smartid) min3 max 6 chars, each char = a...z or 0...9 .
///return global smartid .
// if txt & coordinates empty then will generate unique one, circle needs to be specified if new one
fn gid_new(args GlobalIdNewArgs) !GlobalId {
	mut o := GlobalId{}
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
		o.circle = r[1]
		o.obj = r[2]
	} else if r.len == 1 {
		o.circle = r[0]
		o.obj = r[1]
	} else if r.len == 0 {
		o.obj = r[0]
	} else {
		return error('gsmartid string not properly constructed.\n${gid}')
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
