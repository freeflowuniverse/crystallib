module timetools

import time

pub struct Expiration {
pub mut:
	// expiration in epoch
	expiration i64
}

//? function purpose?
fn (mut exp Expiration) epoch() i64 {
	return exp.expiration
}

//? function purpose?
fn (mut exp Expiration) time() time.Time {
	return time.unix(exp.expiration)
}


//+1h +1s +1d +1m
// 0 means nothing
// h = hour, s=sec, d=day, m=month
// TODO: need to support absolute days
// TODO: do error handling
pub fn expiration_new(exp_ string) ?Expiration {
	relative_time := true // TESTING PLACEHOLDER
	// TODO: function to determine if relative or absolute time
	if relative_time == true{
		// removes all spaces from the string
		mut full_exp:= exp_.replace(' ', '')

		// If input is empty or contains just a 0
		if full_exp == '' || full_exp.trim(' ') == '0' {
		return Expiration{
			expiration: time.now().unix_time()
		}
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
				mult = 60*60
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
		expir := total + time.now().unix_time()
		return Expiration{
		expiration: expir
		}
	}
	// handling for absolute inputs
	// else {}
	return error('could not parse time')
}
	


//get vlang time object but based on string
// e.g. +1h is supported 
// 
// - s -> second
// - h -> hour
// - d -> day
// - w -> week
// - M -> month
// - Q -> quarter
// - Y -> year
//
// of normal format 
// "YYYY-MM-DD HH:mm:ss" format
pub fn get(timestr string) ?time.Time{
	if timestr.trim_space().starts_with("+"){
		mut e:=expiration_new(timestr)?
		return e.time()
	}
	return time.parse(timestr)
}

