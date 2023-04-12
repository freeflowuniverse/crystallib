module params

import freeflowuniverse.crystallib.currency
// import texttools
// import os
import time

// see currency object, gets it from params
pub fn (params &Params) get_currencyamount(key string) !currency.Amount {
	valuestr := params.get(key)!
	mut cs := currency.new()!
	return cs.amount_get(valuestr)!
}

pub fn (params &Params) get_currencyamount_default(key string, defval string) !currency.Amount {
	if params.exists(key) {
		return params.get_currencyamount(key)!
	}
	mut cs := currency.new()!
	return cs.amount_get(defval)!
}

// get currency expressed in float in line to currency passed
pub fn (params &Params) get_currencyfloat(key string) !currency.Amount {
	mut cs := currency.new()!
	valuestr := params.get(key)!
	return cs.amount_get(valuestr)!
}

pub fn (params &Params) get_currencyfloat_default(key string, defval currency.Amount) !currency.Amount {
	if params.exists(key) {
		return params.get_currencyamount(key)!
	}
	return defval
}

// fn (mut cs Currencies) default_set(cur string, usdval f64) {
// 	cur2 := cur.trim_space().to_upper()
// 	mut c1 := Currency{
// 		name: cur2
// 		usdval: usdval
// 	}
// 	cs.currencies[cur2] = &c1
// }
