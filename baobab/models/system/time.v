module system

import time

pub struct OurTime {
pub mut:
	unix u32
}

// print the wiki formatting for time
pub fn (ourtime OurTime) md() string {
	return ourtime.time().format()
}

pub fn (ourtime OurTime) str() string {
	return ourtime.time().format()
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
