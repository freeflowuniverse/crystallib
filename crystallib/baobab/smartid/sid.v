module smartid

import freeflowuniverse.crystallib.clients.redisclient
import math
import freeflowuniverse.crystallib.core.texttools.regext
// import rand

// each part min3 max 6 chars, each char = a...z or 0...9
// to create a new one we need to know the circle
fn sid_new(cid string) !string {
	mut redis := redisclient.core_get()!
	key:='circle:sid:${cid}'
	mut sidlast := redis.get(key)! // is the last sid
	if sidlast==""{
		redis.set(key, '10')!
		sidlast = redis.get(key)! //need to make sure we reserve the first 10 ones
	}
	sidlasti := sidlast.u32()+1 //is a new one
	redis.set(key, '${sidlasti}')!
	return sid_str(sidlasti)
}

// make sure redis knows about it, will return true if its not known in redis yet
fn sid_acknowledge(cid string, sid string) !bool {
	mut redis := redisclient.core_get()!
	key:='circle:sid:${cid}'
	sidlast := redis.get(key)! // is the last sid
	sidlasti := sidlast.u32() 
	sidnewi := sid_int(sid)
	if sidnewi > sidlasti {
		redis.set(key, '${sidnewi}')!
		return true
	}
	return false
}

// set the sids in redis, so we remember them all, and we know which one is the latest 
// this is for all sids as found in text
fn sids_acknowledge(cid string,text string) ! {
	res := regext.find_sid(text)
	for sid in res {
		sid_acknowledge(cid, sid)!
	}
}


// // make sure that we don't use an existing one
// pub fn sid_new_unique(existing []string) !string {
// 	idint := rand.u32_in_range(1, 42800) or { panic(err) }
// 	idstr := smartid_string(idint)
// 	if idstr !in existing {
// 		return idstr
// 	}
// 	return error('Could not find unique smartid, run out of tries')
// }

// convert sid to int
pub fn sid_int(sid string) u32 {
	mut result := 0
	mut count := sid.len - 1
	for i in sid {
		if i > 47 && i < 58 {
			result += (i - 48) * int(math.pow(36, count))
		} else if i > 96 && i < 123 {
			result += (i - 87) * int(math.pow(36, count))
		}
		count -= 1
	}
	return u32(result)
}

// represent sid as string, from u32
fn sid_str(sid u32) string {
	mut completed := false
	mut remaining := int(sid)
	mut decimals := []f64{}
	mut count := 1
	for completed == false {
		if int(math.pow(36, count)) > sid {
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

// check if format is [..5].[..5].[..5] . and [..5] is string
// return error if issue
fn sid_check(sid string) bool {
	if sid.len > 6 || sid.len < 2 {
		return false
	}
	for cha in sid {
		if (cha < 48 || cha > 57) && (cha < 97 || cha > 122) {
			return false
		}
	}
	return true
}

// raise error if smartid not valid
fn sid_test(sid string) ! {
	if !sid_check(sid) {
		return error('sid:${sid} is not valid.')
	}
}


