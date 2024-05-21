module ourtime

import time

pub struct OurTime {
pub mut:
	unixt i64
}

// Get Expiration object from time string input .
// input can be either relative or absolute .
// if input is empty then is now
// ```
// ## Relative time
// #### time periods:
// - s : second
// - h : hour
// - d : day
// - w : week
// - M : month
// - Q : quarter
// - Y : year
// 0 means right now
// input string example: "+1w +2d -4h"
//
// ## Absolute time
// inputs must be of the form: "YYYY-MM-DD HH:mm:ss" or "YYYY-MM-DD"
// the time can be HH:mm:ss or HH:mm
// inputs also supported are: "DD-MM-YYYY" but then the YYYY needs to be 4 chars
// for date we also support / in stead of -
// input string examples:
//
//'2022-12-5 20:14:35'
//'2022-12-5' - sets hours, mins, seconds to 00
//
// ```
pub fn new(txt_ string) !OurTime {
	if txt_.trim_space() == '' {
		mut ot := OurTime{}
		ot.now()
		return ot
	}
	unixt := parse(txt_)!
	return OurTime{
		unixt: unixt
	}
}

pub fn new_from_epoch(ut u64) OurTime {
	mut ot := OurTime{
		unixt: ut
	}
	return ot
}

pub fn now() OurTime {
	mut ot := OurTime{}
	ot.now()
	return ot
}

// will check if the time is empty, if yes then will fill it in
pub fn (mut ot OurTime) check() {
	if ot.unixt == 0 {
		ot.now()
	}
}

// print the wiki formatting for time
pub fn (ot OurTime) md() string {
	return ot.time().format()
}

// format as a usable key .
// "YYYY_MM_DD_HH_mm_ss"
pub fn (ot OurTime) key() string {
	t := ot.time()
	mut o := t.ymmdd() + '_' + t.hhmmss()
	o = o.replace('-', '_')
	o = o.replace(':', '_')
	return o
}

// returns a date-time string in "YYYY-MM-DD HH:mm" format (24h).
pub fn (ot OurTime) str() string {
	return ot.time().format()
}

// returns a date string in "YYYY-MM-DD" format
pub fn (ot OurTime) day() string {
	return ot.time().ymmdd()
}

// returns as epoch (seconds)
pub fn (ot OurTime) int() int {
	return int(ot.time().unix())
}

// set ourtime to now
pub fn (mut t OurTime) now() {
	t.unixt = i64(time.now().unix())
}

// get time from vlang
pub fn (t OurTime) time() time.Time {
	return time.unix(i64(t.unixt))
}

// get time from vlang
pub fn (t OurTime) unix() i64 {
	return t.unixt
}

pub fn (t OurTime) empty() bool {
	return t.unixt == 0
}

// move the time, e.g. +1h means we go 1 h further
// ## Relative time
// #### time periods:
// - s : second
// - h : hour
// - d : day
// - w : week
// - M : month
// - Q : quarter
// - Y : year
// input string example: "+1w +2d -4h"
//
pub fn (mut t OurTime) warp(warp string) ! {
	println(relative_sec(warp)!)
	t.unixt += relative_sec(warp)!
}
