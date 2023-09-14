module spreadsheet

import math

pub enum ReprType {
	number // will use k, m, ...
	currency
}

// represent a
pub fn float_repr(nr_ f64, reprtype ReprType) string {
	mut out := ''
	mut nr := nr_
	mut nr_pos := math.abs(nr)
	mut ext := ''
	if reprtype == .number || reprtype == .currency {
		if nr_pos > 1000 * 1000 {
			nr = nr / 1000000
			ext = 'm'
		} else if nr_pos > 1000 {
			ext = 'k'
			nr = nr / 1000
		}
		if nr > 1000 {
			out = '${nr:.0}${ext}'
		} else if nr > 100 {
			out = '${nr:.1}${ext}'
		} else {
			out = '${nr:.2}${ext}'
		}
	}
	return out
}
