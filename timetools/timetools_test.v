import freeflowuniverse.crystallib.timetools
import time

fn check_input(input_string string, seconds int) {
	nnow := time.now().unix_time()
	exp := timetools.get_expiration_from_timestring(input_string) or {
		panic('cannot get expiration for ${input_string}')
	}
	assert exp.expiration == (nnow + seconds), 'expiration was incorrect for ${input_string}'
}

// check every period
fn test_every_period() {
	input_strings := {
		'+5s': 5
		'+3m': 180
		'+2h': 7200
		'+1d': 86_400
		'+1w': 604_800
		'+1M': 2_592_000
		'+1Q': 7_776_000
		'+1Y': 31_536_000
	}

	for key, value in input_strings {
		check_input(key, value)
	}
}

// check multiple periods input
fn test_combined_periods() {
	input_strings := {
		'+5s +1h +1d': 90_005
		'+1h +2s +1Y': 31_539_602
	}

	for key, value in input_strings {
		check_input(key, value)
	}
}

// check negative inputs
fn test_negative_periods() {
	input_strings := {
		'-15s': -15
		'-5m':  -300
		'-2h':  -7200
		'-1d':  -86_400
		'-1w':  -604_800
		'-1M':  -2_592_000
		'-1Q':  -7_776_000
		'-1Y':  -31_536_000
	}

	for key, value in input_strings {
		check_input(key, value)
	}
}

// check positive and negative combinations
fn test_combined_signs() {
	input_strings := {
		'+1h -10s':             3_590
		'+1d -2h':              79_200
		'+1Y -2Q +2M +4h -60s': 21_182_340
	}

	for key, value in input_strings {
		check_input(key, value)
	}
}

// check varied input styles
fn test_input_variations() {
	input_strings := {
		'   +1s   ':     1
		' - 1 s ':       -1
		'+    1s-1h ':   -3599
		'- 1s+   1   h': 3599
	}

	for key, value in input_strings {
		check_input(key, value)
	}
}

// check that standard formats can be inputted
fn test_absolute_time() {
	input_strings := {
		'2022-12-5 20:14:35': 1670260475
		'2022-12-5':          1670187600
		'2022-12':            1669842000 // Should be the beginning of december
		'2022':               1640984400 // should be beginning of 2022
	}
	for key, value in input_strings {
		exp := timetools.get_expiration_from_timestring(key) or {
			panic('cannot get expiration for ${key}')
		}
		assert exp.expiration == value, 'expiration was incorrect for ${key}'
	}
}

fn test_parse_date() {
	input_strings := {
		'12 jan':    {
			'month': 1
			'day':   12
		}
		'09 sep':    {
			'month': 9
			'day':   9
		}
		'7december': {
			'month': 12
			'day':   7
		}
		'feb28':     {
			'month': 2
			'day':   28
		}
	}

	for key, value in input_strings {
		test_value := timetools.parse_date(key) or {
			panic('parse_date failed for ${key}, with error ${err}')
		}
		assert test_value == value, 'month, day was incorrect for ${key}'
	}
}

fn test_parse_time() {
	input_strings := {
		'12:20':   {
			'hour':   12
			'minute': 20
		}
		'15;30':   {
			'hour':   15
			'minute': 30
		}
		'12:30pm': {
			'hour':   12
			'minute': 30
		}
		'3pm':     {
			'hour':   15
			'minute': 0
		}
		'8.40 pm': {
			'hour':   20
			'minute': 40
		}
	}

	for key, value in input_strings {
		test_value := timetools.parse_time(key) or {
			panic('parse_time failed for ${key}, with error ${err}')
		}
		assert test_value == value, 'hour, minute was incorrect for ${key}'
	}
}


// BACKLOG: need to have more complete examples for absolute time