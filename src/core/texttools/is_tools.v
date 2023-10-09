module texttools

import strconv

pub fn is_int(text string) bool {
	strconv.parse_uint(text, 10, 32) or { return false }
	return true
}
