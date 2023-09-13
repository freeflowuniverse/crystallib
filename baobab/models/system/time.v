module system

import time

pub struct OurTime {
pub mut:
	unix i64
}

// go from YYYY/MM/DD to OurTime .
// its done following iso8601: https://en.wikipedia.org/wiki/ISO_8601
pub fn to_ourtime(txt_ string) !OurTime {
	mut txt := txt_
	split := txt.split('/')
	if split.len != 3 {
		return error('unrecognized time format, time must either be YYYY/MM/DD or DD/MM/YYYY')
	}
	if split[2].len == 4 {
		txt = split.reverse().join('-')
	} else if !(split[0].len == 4) {
		return error('unrecognized time format, time must either be YYYY/MM/DD or DD/MM/YYYY')
	}
	println(txt)
	ttime := time.parse_iso8601(txt)!
	return OurTime{
		unix: ttime.unix_time()
	}
}

// print the wiki formatting for time
pub fn (ourtime OurTime) md() string {
	return ourtime.time().format()
}

pub fn (ourtime OurTime) str() string {
	return ourtime.time().format()
}

// returns a date string in "YYYY-MM-DD" format
pub fn (ourtime OurTime) day() string {
	return ourtime.time().ymmdd()
}

pub fn (ourtime OurTime) int() int {
	return int(ourtime.time().unix_time())
}

pub fn (mut t OurTime) now() {
	t.unix = u32(time.now().unix_time())
}

// get time from vlang
pub fn (t OurTime) time() time.Time {
	return time.unix(i64(t.unix))
}
