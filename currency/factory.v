module currency

import os

__global (
	currencies shared map[string]Currency
)

// fn init() {
// 	currencies.init()
// }


fn check() {
	if currencies.len==0{
		refresh()
	}
}

pub fn refresh() {
	println('FETCHCURRENCIES')
	defaults_set()
	env := os.environ()
	egpval := (1 / 32)
	if 'OFFLINE' in env {
		// compensate for internet not being there
		default_set('EUR', 0.9)
		default_set('AED', 0.25)
		default_set('EGP', egpval)
		default_set('USD', 1.0)
		default_set('TFT', 0.01)
		default_set('USDC', 1.0)
	} else {
		rates_get(['EUR', 'AED', 'USD', 'EGP'], false) or { panic(err) }
		rates_get(['TERRA', 'TFT', 'XLM', 'USDC'], true) or { panic(err) }
	}
}


//get a currency object based on the name
pub fn get(name_ string) !Currency {
	mut name := name_.to_upper().trim_space()
	check()
	rlock currencies {
		return currencies[name] or { return error('Could not find currency ${name}') }
	}
	panic("bug")
}


