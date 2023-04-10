module params

import freeflowuniverse.crystallib.timetools
// import texttools
// import os
import time { Duration, Time }

// Get Expiration object from time string input
// input can be either relative or absolute
// ## Relative time
// #### time periods:
// - s -> second
// - h -> hour
// - d -> day
// - w -> week
// - M -> month
// - Q -> quarter
// - Y -> year
// 0 means right now
// input string example: "+1w +2d -4h"
// ## Absolute time
// inputs must be of the form: "YYYY-MM-DD HH:mm:ss" or "YYYY-MM-DD"
// input string examples:
//'2022-12-5 20:14:35'
//'2022-12-5' - sets hours, mins, seconds to 00
pub fn (params &Params) get_time(key string) !Time {
	valuestr := params.get(key)!
	return timetools.parse(valuestr)!
}

pub fn (params &Params) get_time_default(key string, defval Time) !Time {
	if params.exists(key) {
		return params.get_time(key)!
	}
	return defval
}

// calculate difference in time, returled as u64 (is Duration type)
// format e.g.
// QUESTION: splitting by - doesn't work? Alternative?
pub fn (params &Params) get_time_interval(key string) !Duration {
	valuestr := params.get(key)!
	data := valuestr.split('-')
	if data.len != 2 {
		return error('Invalid time interval: begin and end time required')
	}
	start := params.get_time(data[0])!
	end := params.get_time(data[1])!
	if end.unix_time() < start.unix_time() {
		return error('Invalid time interval: begin time cannot be after end time')
	}
	return end.unix_time() - start.unix_time()
	// NEXT: document and give examples, make sure there is test
}

// QUESTION: what was purpose of this? Duration is not same as time, think code needs to be removed

// fn (params &Params) parse_time(value string) !Duration {
// 	is_am := value.ends_with('AM')
// 	is_pm := value.ends_with('PM')
// 	is_am_pm := is_am || is_pm
// 	data := if is_am_pm { value[..value.len - 2].split(':') } else { value.split(':') }
// 	if data.len > 2 {
// 		return error('Invalid duration value')
// 	}
// 	minute := if data.len == 2 { data[1].int() } else { 0 }
// 	mut hour := data[0].int()
// 	if is_am || is_pm {
// 		if hour < 0 || hour > 12 {
// 			return error('Invalid duration value')
// 		}
// 		if is_pm {
// 			hour += 12
// 		}
// 	} else {
// 		if hour < 0 || hour > 24 {
// 			return error('Invalid duration value')
// 		}
// 	}
// 	if minute < 0 || minute > 60 {
// 		return error('Invalid duration value')
// 	}
// 	return Duration(time.hour * hour + time.minute * minute)
// }
