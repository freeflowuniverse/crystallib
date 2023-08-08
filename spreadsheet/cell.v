module spreadsheet

pub struct NoVal {}

// type CellVal = currency.Amount | int | f64 | string | NoVal

pub struct Cell {
pub mut:
	val   f64
	row   &Row [skip; str: skip]
	empty bool = true
}

pub fn (mut c Cell) set(v string) ! {
	if c.row.sheet.currency.name != '' {
		// means we insert a currency so need to do the exchange
		mut amount := c.row.sheet.currencies.amount_get(v)!
		if amount.currency.name == '' {
			mut curr2 := c.row.sheet.currencies.currency_get('USD')!
			amount.currency = curr2
		}
		mut amount2 := amount.exchange(c.row.sheet.currency)! // do the exchange to the local currency
		c.val = amount2.val
	} else {
		c.val = v.f64()
	}
	c.empty = false
}

pub fn (mut c Cell) add(v f64) {
	c.val += v
	c.empty = false
}

pub fn (mut c Cell) repr() string {
	// match val {
	// 	currency.Amount {
	// 		valout=val.repr()!
	// 	}
	// 	int {
	// 		valout="$val"
	// 	}
	// 	f64 {
	// 		valout="$val"
	// 	}
	// 	string {
	// 		valout="$val"
	// 	}	
	// 	NoVal {
	// 		valout=""
	// 	}				
	// }
	if c.empty {
		return '-'
	}
	return float_repr(c.val, c.row.reprtype)
}

pub fn (mut c Cell) str() string {
	return c.repr()
}
