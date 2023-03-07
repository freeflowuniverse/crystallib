module currency

pub fn new() !Currencies {
	mut cs := Currencies{}
	cs.defaults_set()
	cs.get_rates(['EUR', 'AED', 'USD', 'EGP'], false)!
	cs.get_rates(['TERRA', 'TFT', 'XLM', 'USDC'], true)!
	return cs
}
