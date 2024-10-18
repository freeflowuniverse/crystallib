module spreadsheet

import freeflowuniverse.crystallib.data.currency

pub struct Cell {
pub mut:
	val   f64
	row   &Row @[skip; str: skip]
	empty bool = true
}

pub fn (mut c Cell) set(v string) ! {
	// means we insert a currency so need to do the exchange
	mut amount := currency.amount_get(v)!
	assert amount.currency.name != ''
	mut amount2 := amount.exchange(c.row.sheet.currency)! // do the exchange to the local currency
	c.val = amount2.val
	c.empty = false
}

pub fn (mut c Cell) add(v f64) {
	c.val += v
	c.empty = false
}

pub fn (mut c Cell) repr() string {
	if c.empty {
		return '-'
	}
	return float_repr(c.val, c.row.reprtype)
}

pub fn (mut c Cell) str() string {
	return c.repr()
}
