module coinmarketcap

fn test_1() {

	key := "92be9b29-7f6c-48e4-9ef2-d6aa0550f620"
	mut args := CMCNewArgs{secret:key}
	mut c := new(args)
	prefix := "cryptocurrency/quotes/latest"
	data := ""
	query := "symbol=TFT"
	cache := true
	result := c.get_json_str(prefix, data, query, cache) or {panic(err)}
	println(result)

	//need to fetch USD/TFT price
	//see how we did for taiga how to use the connection



	panic("sss")

}