module ourtime

import time

// const (
// 	numbers = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0']
// 	letters = ['a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p',
// 		'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z']

// 	months  = {
// 		'january':   1
// 		'february':  2
// 		'march':     3
// 		'april':     4
// 		'may':       5
// 		'june':      6
// 		'july':      7
// 		'august':    8
// 		'september': 9
// 		'october':   10
// 		'november':  11
// 		'december':  12
// 	}
// )

fn parse(timestr string) !i64 {
	trimmed := timestr.trim_space()
	if trimmed == '' {
		n := now()
		time_unix := n.unix_time()
		return time_unix
	}
	mut relative_bool := false
	if trimmed.starts_with('+') || trimmed.starts_with('-') {
		relative_bool = true
	}

	if relative_bool == true {
		time_unix := get_unix_from_relative(trimmed) or {
			return error('Failed to get unix from relative time: ${err}')
		}
		return time_unix
	} else {
		time_unix := get_unix_from_absolute(trimmed) or {
			return error('Failed to get unix from absolute time: ${err}')
		}
		return time_unix
	}
	return error('bug')
}

fn relative_sec(timestr string) !i64 {
	// removes all spaces from the string
	mut full_exp := timestr.replace(' ', '')

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
	return total
}

fn get_unix_from_relative(timestr string) !i64 {
	r := relative_sec(timestr)!
	time_unix := i64(r) + time.now().unix_time()
	return time_unix
}

pub fn get_unix_from_absolute(timestr_ string) !i64 {
	timestr := timestr_.trim_space()
	split_time_hour := timestr.split(' ')
	if split_time_hour.len > 2 {
		return error('format of date/time not correct: ${timestr_}')
	}
	mut datepart := ''
	mut timepart := ''
	if split_time_hour.len == 2 {
		// there is a date and time part
		datepart = split_time_hour[0]
		timepart = split_time_hour[1]
	} else if split_time_hour.len == 2 {
		datepart = split_time_hour[0]
	} else {
		return error("format of date/time not correct: '${timestr_}'")
	}
	datepart = datepart.replace('/', '-')
	if timepart.contains('-') || timepart.contains('/') {
		return error("format of date/time not correct, no - or / in time: '${timestr_}'")
	}

	split := datepart.split(':')
	if split.len != 3 {
		return error("unrecognized dat format, time must either be YYYY/MM/DD or DD/MM/YYYY, or : in stead of /. Input was:'${timestr_}'")
	}
	if split[2].len == 4 {
		datepart = split.reverse().join('-')
	} else if !(split[0].len == 4) {
		return error("unrecognized time format, time must either be YYYY/MM/DD or DD/MM/YYYY, or : in stead of /. Input was:'${timestr_}'")
	}

	timparts := timepart.split(':')
	if timparts.len == 2 {
		timepart = '${timepart}:00'
	} else if timparts.len == 1 {
		timepart = '${timepart}:00:00'
	} else if timparts.len == 0 {
		timepart = '00:00:00'
	} else {
		return error("format of date/time not correct, in time part: '${timestr_}'")
	}

	full_string := '${datepart} ${timepart}'

	time_struct := time.parse(full_string) or {
		return error("could not parse date/time string '${timestr_}': ${err}")
	}
	return time_struct.unix_time()
}
