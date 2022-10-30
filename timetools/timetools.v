module timetools

import time

pub struct Expiration {
pub mut:
	// expiration in epoch
	expiration i64
}

// Get unix time from Expiration object
fn (mut exp Expiration) epoch() i64 {
	return exp.expiration
}

// Get Time object from Expiration object
pub fn (mut exp Expiration) to_time() time.Time {
	return time.unix(exp.expiration)
}

pub fn time_from_string(timestr string) !time.Time {
	mut exp_ := get_expiration_from_timestring(timestr)!
	time_object := exp_.to_time()
	return time_object
}

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
// TODO: do error handling
pub fn get_expiration_from_timestring(exp_ string) !Expiration { // TODO: function to determine if relative or absolute time
	trimmed := exp_.trim_space()
	mut relative_bool := false
	if trimmed.starts_with('+') || trimmed.starts_with('-') {
		relative_bool = true
	}

	if relative_bool == true {
		time_unix := get_unix_from_relative(exp_) or {
			return error('Failed to get unix from relative time: $err')
		}
		return Expiration{
			expiration: time_unix
		}
	} else {
		time_unix := get_unix_from_absolute(exp_) or {
			return error('Failed to get unix from absolute time: $err')
		}
		return Expiration{
			expiration: time_unix
		}
	}
}

pub fn get_unix_from_relative(exp_ string) !i64 {
	// removes all spaces from the string
	mut full_exp := exp_.replace(' ', '')

	// If input is empty or contains just a 0
	if full_exp == '' || full_exp.trim(' ') == '0' {
		time_unix := time.now().unix_time()
		return time_unix
	}

	// duplicates the + and - signs
	full_exp = full_exp.replace('+', '£+')
	full_exp = full_exp.replace('-', '£-')
	// create an array of periods
	mut exps := full_exp.split_any('£')
	exps = exps.filter(it.len > 0)
	mut total := 0

	for mut exp in exps {
		mut mult := 0
		if exp.ends_with('s') {
			mult = 1
		} else if exp.ends_with('m') {
			mult = 60
		} else if exp.ends_with('h') {
			mult = 60 * 60
		} else if exp.ends_with('d') {
			mult = 60 * 60 * 24
		} else if exp.ends_with('w') {
			mult = 60 * 60 * 24 * 7
		} else if exp.ends_with('M') {
			mult = 60 * 60 * 24 * 30
		} else if exp.ends_with('Q') {
			mult = 60 * 60 * 24 * 30 * 3
		} else if exp.ends_with('Y') {
			mult = 60 * 60 * 24 * 365
		} else {
			return error('could not parse time suffix for: $exp')
		}
		if exp.starts_with('-') {
			mult *= -1
		}
		// remove +/- and period
		exp = exp[1..(exp.len - 1)]
		// multiplies the value by the multiplier
		exp_int := exp.int() * mult
		total += exp_int
	}
	time_unix := total + time.now().unix_time()
	return time_unix
}

pub fn get_unix_from_absolute(timestr string) !i64 {
	components := timestr.split_any(' :-')
	mut full_string := timestr
	if components.len == 3 {
		full_string = timestr.replace(':', '-') + " 00:00:00"
	} else if components.len == 2 {
		full_string = timestr.replace(':', '-') + "-01 00:00:00"
	} else if components.len == 1 {
		full_string = timestr.replace(':', '-') + "-01-01 00:00:00"
	}

	time_struct := time.parse(full_string) or { return error('could not parse time string: $err') }
	return time_struct.unix_time() - 10_800
}
