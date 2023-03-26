module params

import freeflowuniverse.crystallib.currency
import texttools
import os
import time { Duration, Time }


//see currency object, gets it from params
pub fn (params &Params) get_currencyamount(key string) !currency.Amount {
	mut cs := currency.new()!
	valuestr := params.get(key)!
	return cs.amount_get(valuestr)!
}

pub fn (params &Params) get_currencyamount_default(key string, defval currency.Amount) !currency.Amount {
	if params.exists(key) {
		return params.get_currencyamount(key)!
	}
	return defval
}
