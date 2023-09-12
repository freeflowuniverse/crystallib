module system

import time

pub struct OurTime {
pub mut:
	unix u32
}

//go from YYYY/MM/DD to OurTime .
//its done following iso8601: https://en.wikipedia.org/wiki/ISO_8601
pub fn to_ourtime(txt string) !OurTime {
	ttime:=parse_iso8601(txt)!
	return OurTime{
		unix:ttime.unix_time()
	}
}


// print the wiki formatting for time
pub fn (ourtime OurTime) md() string {
	return ourtime.time().format()
}

pub fn (ourtime OurTime) str() string {
	return ourtime.time().format()
}

//returns a date string in "YYYY-MM-DD" format
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
