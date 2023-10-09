module params

// import freeflowuniverse.crystallib.data.currency
// import freeflowuniverse.crystallib.core.texttools
// import os

// TODO: fix if necessary
// // see currency object, gets it from params
// pub fn (params &Params) get_currencyamount(mut cs currency.Currencies, key string) !currency.Amount {
// 	valuestr := params.get(key)!
// 	return cs.amount_get(valuestr)!
// }

// pub fn (params &Params) get_currencyamount_default(mut cs currency.Currencies, key string, defval string) !currency.Amount {
// 	if params.exists(key) {
// 		return params.get_currencyamount(mut cs, key)!
// 	}
// 	return cs.amount_get(defval)!
// }

// // get currency expressed in float in line to currency passed
// pub fn (params &Params) get_currencyfloat(mut cs currency.Currencies, key string) !f64 {
// 	valuestr := params.get(key)!
// 	a := cs.amount_get(valuestr)!
// 	return a.val
// }

// pub fn (params &Params) get_currencyfloat_default(mut cs currency.Currencies, key string, defval f64) !f64 {
// 	if params.exists(key) {
// 		return params.get_currencyfloat(mut cs, key)!
// 	}
// 	return defval
// }

// fn (mut cs Currencies) default_set(cur string, usdval f64) {
// 	cur2 := cur.trim_space().to_upper()
// 	mut c1 := Currency{
// 		name: cur2
// 		usdval: usdval
// 	}
// 	cs.currencies[cur2] = &c1
// }
