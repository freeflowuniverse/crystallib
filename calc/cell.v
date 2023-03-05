module calc

import freeflowuniverse.crystallib.currency

pub struct NoVal{}

type CellVal = currency.Amount | int | f64 | string | NoVal

pub struct Cell{
pub mut:
	name string
	cell CellVal
	row &Row [str: skip]
}

pub fn (mut c Cell) repr() str {
	val:=c.cell
	mut valout := ''
	match val {
		currency.Amount {
			valout=val.repr()!
		}
		int {
			valout="$val"
		}
		f64 {
			valout="$val"
		}
		string {
			valout="$val"
		}	
		NoVal {
			valout=""
		}				
	}
	return valout
}
