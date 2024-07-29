module farmingsimulator

// //calculates the token retur for farming
// fn (mut ri RegionalInternet) token_cultivation(node_template NodeTemplate, month int)!f64 {

// 	utilization_nodes

// 	cu := node_template.capacity.cloudunits.cu
// 	su := node_template.capacity.cloudunits.su
// 	nu:= node_template.capacity.cloudunits.nu

// 	utilization_nodes := ri.sheet.row_get("utilization_nodes")!

// 	chi_price_usd:=ri.sheet.row_get("chi_price_usd")!
// 	mut chi_price_usd_now := chi_price_usd.cells[month].val

// 	//https://docs.google.com/spreadsheets/d/1KQGxaQuMOdy16H68SeSaWYqOyblzvSHvAcpcCdyMp6w/edit#gid=111700120

// 	//expressed in USD
// 	token_farming_usd := cu * 2.4 + su * 1 + nu * 0.03
// 	println("++ $month $chi_total_tokens_now_million:: $chi_max_tokens_million")
// 	token_farming_usd_after_difficulty := token_farming_usd * (1-(chi_total_tokens_now_million/chi_max_tokens_million))

// 	token_farming_chi := token_farming_usd_after_difficulty / chi_price_usd_now

// 	// println(node_template)
// 	// println(chi_price_usd_now)
// 	// println(token_farming_chi)

// 	return token_farming_chi

// }
