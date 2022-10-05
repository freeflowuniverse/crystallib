module timetools

import time

pub struct Expiration {
pub mut:
	// expiration in epoch
	expiration i64
}

fn (mut exp Expiration) epoch() i64 {
	return exp.expiration
}

fn (mut exp Expiration) time() time.Time {
	return time.unix(exp.expiration)
}


//+1h +1s +1d +1m
// 0 means nothing
// h = hour, s=sec, d=day, m=month
// TODO: need to support absolute days
pub fn expiration_new(exp_ string) ?Expiration {
	nnow := time.now().unix_time()
	mut exp := exp_.trim(' ')
	if exp == '' || exp.trim(' ') == '0' {
		return Expiration{
			expiration: nnow
		}
	}
	if exp.starts_with('+') {
		mut mult := 0
		if exp.ends_with('h') {
			mult = 60 * 60
		} else if exp.ends_with('s') {
			mult = 1
		} else if exp.ends_with('d') {
			mult = 60 * 60 * 24
		} else if exp.ends_with('M') {
			mult = 60 * 60 * 24 * 30	
		} else if exp.ends_with('W') {
			mult = 60 * 60 * 24 * 7	
		} else if exp.ends_with('Y') {
			mult = 60 * 60 * 24 * 365	
		} else {
			return error('could not parse time:$exp')
		}
		// remove + and perdiod
		exp = exp[1..(exp.len - 2)]
		exp_int := exp.int() * mult + nnow
		return Expiration{
			expiration: exp_int
		}
	}
	return error('could not parse time:$exp')
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