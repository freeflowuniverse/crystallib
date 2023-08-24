module currency

import os

pub fn new() &Currencies {
	println("FETCHCURRENCIES")
	mut cs:=Currencies{}
	cs.defaults_set()
	env := os.environ()
	egpval := (1 / 32)
	if 'OFFLINE' in env {
		// compensate for internet not being there
		cs.default_set('EUR', 0.9)
		cs.default_set('AED', 0.25)
		cs.default_set('EGP', egpval)
		cs.default_set('USD', 1.0)
		cs.default_set('TFT', 0.01)
		cs.default_set('USDC', 1.0)
	} else {
		cs.get_rates(['EUR', 'AED', 'USD', 'EGP'], false) or {panic(err)}
		cs.get_rates(['TERRA', 'TFT', 'XLM', 'USDC'], true) or {panic(err)}
	}
	return &cs
}
