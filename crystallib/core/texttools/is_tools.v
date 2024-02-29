module texttools

import strconv

pub fn is_int(text string) bool {
	for cha in text {
		if cha < 48 || cha > 57 {
			return false
		}
	}
	return true
}


pub fn is_upper_text(text string) bool {
	for cha in text {
		if cha < 65 || cha > 90 {
			return false
		}
	}
	return true
}




// fn sid_check(sid string) bool {
// 	if sid.len > 6 || sid.len < 2 {
// 		return false
// 	}
// 	for cha in sid {
// 		if (cha < 48 || cha > 57) && (cha < 97 || cha > 122) {
// 			return false
// 		}
// 	}
// 	return true
// }
