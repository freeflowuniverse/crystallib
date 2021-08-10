module timetools

import time

pub struct Expiration {
pub mut:
	// expiration in epoch
	expiration int
}

fn (mut exp Expiration) epoch() int {
	return exp.expiration
}

//+1h +1s +1d +1m
// 0 means nothing
// h = hour, s=sec, d=day, m=month
// TODO: need to support absolute days
pub fn expiration_new(exp_ string) ?Expiration {
	nnow := time.now().unix_time()
	mut exp := exp_.trim(' ').to_lower()
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
		} else if exp.ends_with('m') {
			mult = 60
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
