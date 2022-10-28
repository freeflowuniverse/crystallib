import freeflowuniverse.crystallib.timetools
import time

fn check_input(input_string string, seconds int) {
	nnow := time.now().unix_time()
	exp := timetools.get_expiration_from_timestring(input_string) or {
		panic('cannot get expiration for $input_string')
	}
	assert exp.expiration == (nnow + seconds), 'expiration was incorrect for $input_string'
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
	'2022-12-5': 1670187600
	'2022-12': 1669842000 // Should be the beginning of december
	'2022': 1640984400 // should be beginning of 2022
	}
	for key, value in input_strings {
		exp := timetools.get_expiration_from_timestring(key) or {
			panic('cannot get expiration for $key')
		}
		assert exp.expiration == value, 'expiration was incorrect for $key'
	}
}
