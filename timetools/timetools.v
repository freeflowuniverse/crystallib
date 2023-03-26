module timetools

import time

const (
	numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0']
	letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
		'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']

	months  = {
		'january':   1
		'february':  2
		'march':     3
		'april':     4
		'may':       5
		'june':      6
		'july':      7
		'august':    8
		'september': 9
		'october':   10
		'november':  11
		'december':  12
	}
)

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
pub fn get_expiration_from_timestring(exp_ string) !Expiration { 
	// BACKLOG: function to determine if relative or absolute time, or is maybe done
	trimmed := exp_.trim_space()
	mut relative_bool := false
	if trimmed.starts_with('+') || trimmed.starts_with('-') {
		relative_bool = true
	}

	if relative_bool == true {
		time_unix := get_unix_from_relative(exp_) or {
			return error('Failed to get unix from relative time: ${err}')
		}
		return Expiration{
			expiration: time_unix
		}
	} else {
		time_unix := get_unix_from_absolute(exp_) or {
			return error('Failed to get unix from absolute time: ${err}')
		}
		return Expiration{
			expiration: time_unix
		}
	}
	// BACKLOG: do error handling	
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
			return error('could not parse time suffix for: ${exp}')
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
		full_string = timestr.replace(':', '-') + ' 00:00:00'
	} else if components.len == 2 {
		full_string = timestr.replace(':', '-') + '-01 00:00:00'
	} else if components.len == 1 {
		full_string = timestr.replace(':', '-') + '-01-01 00:00:00'
	}

	time_struct := time.parse(full_string) or {
		return error('could not parse time string: ${err}')
	}
	return time_struct.unix_time() - 10_800
}

pub fn parse_date(datestr_ string) !map[string]int {
	mut datestr_list := datestr_.to_lower().replace(' ', '').split('')

	mut day := ''
	mut month_str := ''

	for char_ in datestr_list {
		if char_ in timetools.numbers {
			day += char_
		} else {
			month_str += char_
		}
	}

	mut month_int := 0
	mut month_found := false
	for month, value in timetools.months {
		if month.contains(month_str) {
			month_int = value
			month_found = true
		}
	}

	if month_found == false {
		return error('Month could not be identified')
	}

	if day.int() > 31 {
		return error('Day value too large')
	}

	return {
		'month': month_int
		'day':   day.int()
	}
}

pub fn parse_time(timestr_ string) !map[string]int {
	mut clean_time := timestr_.replace_each([';', ':', '.', ':', ',', ':', ' ', '']).to_lower()
	mut identifier := ''
	mut no_letter_time := ''

	for char_ in clean_time.split('') {
		if char_ in timetools.letters {
			identifier += char_
		} else {
			no_letter_time += char_
		}
	}

	time_parts := no_letter_time.split(':')

	mut hour := time_parts[0].int()
	mut minute := 0

	if time_parts.len != 1 {
		minute = time_parts[1].int()
	}

	if identifier == 'pm' && hour != 12 {
		hour += 12
	}

	if hour > 24 {
		return error('Hour given is too great')
	} else if minute > 59 {
		return error('Minute given is too great')
	}

	return {
		'hour':   hour
		'minute': minute
	}
}
