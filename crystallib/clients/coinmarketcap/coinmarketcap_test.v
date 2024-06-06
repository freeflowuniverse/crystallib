module coinmarketcap

import freeflowuniverse.crystallib.ui.console

fn test_get_tft_price() {
	key := '92be9b29-7f6c-48e4-9ef2-d6aa0550f620'
	mut args := CMCNewArgs{
		secret: key
	}
	mut c := new(args)!

	// TFT/USD price
	price := c.token_price_usd() or { panic(err) }
	console.print_debug(' 1 TFT = ${price} USD')
}
