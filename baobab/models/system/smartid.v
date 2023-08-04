module system

import math

// global smart if, represents an object on global level
pub struct SmartId {
pub mut:
	region u32
	circle u32
	obj    u32
}

// smartid is of form region.circle.obj
// each part min3 max 6 chars, each char = a...z or 0...9
pub fn new(sid string) !SmartId {
	return smartdid_new(sid)
}

// return smartid for 2 parts e.g. region and circle
pub fn smartids2_string(sids [2]u32) string {
	return '${smartid_string(sids[0])}.${smartid_string(sids[1])}'
}

fn smartid_int(gsid string) u32 {
	mut result := 0
	mut count := gsid.len - 1
	for i in gsid {
		if i > 47 && i < 58 {
			result += (i - 48) * int(math.pow(36, count))
		} else if i > 96 && i < 123 {
			result += (i - 87) * int(math.pow(36, count))
		}
		count -= 1
	}
	return u32(result)
}

fn smartid_string(gsid u32) string {
	mut completed := false
	mut remaining := int(gsid)
	mut decimals := []f64{}
	mut count := 1
	for completed == false {
		if int(math.pow(36, count)) > gsid {
			for i in 0 .. count {
				decimals << math.floor(f64(remaining / int(math.pow(36, count - 1 - i))))
				remaining = remaining % int(math.pow(36, count - 1 - i))
			}
			completed = true
		} else {
			count += 1
		}
	}
	mut strings := []string{}
	for i in 0 .. (decimals.len) {
		if decimals[i] >= 0 && decimals[i] <= 9 {
			strings << u8(decimals[i] + 48).ascii_str()
		} else {
			strings << u8(decimals[i] + 87).ascii_str()
		}
	}
	return strings.join('')
}

// check if formast is [..5].[..5].[..5] . and [..5] is string
// return error if issue
fn smartid_check(gsid string) bool {
	mut ids := gsid.split('.')
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

///return global smartid
fn smartdid_new(gsid string) !SmartId {
	mut o := SmartId{}
	mut ids := gsid.split('.')
	if ids.len > 3 {
		return error('need format d.d.d max 2 . for a global smartid \n${gsid}')
	}
	mut r := []u32{}
	for id in ids {
		if id.len > 6 || id.len < 2 {
			return error('one of the parts is too small or too large, needs to be 2...5 \n${gsid}')
		}
		for cha in id {
			if (cha < 48 || cha > 57) && (cha < 97 || cha > 122) {
				return error('each char needs to be: a.z, 0.9. \n${gsid}')
			}
		}
		r << smartid_int(id)
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
		return error('gsmartid string not properly constructed.\n${gsid}')
	}

	return o
}
