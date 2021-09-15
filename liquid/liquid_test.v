module liquid

fn test_1() {

	key := "92be9b29-7f6c-48e4-9ef2-d6aa0550f620"
	mut args := LiquidArgs{secret:key}
	mut l := new(args)

	// TFT/USDT price
	pair_tft_usdt := l.token_price_usdt() or {panic(err)}
	println("Market Pid for TFT/USDT pair = $pair_tft_usdt")

	// TFT/BTC price
	pair_tft_btc := l.token_price_btc() or {panic(err)}
	println("Market Pid for TFT/BTC pair = $pair_tft_btc")
}
