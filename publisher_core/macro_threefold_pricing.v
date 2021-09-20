module publisher_core

import coinmarketcap
import liquid
import time
import texttools

const CMCKEY = "92be9b29-7f6c-48e4-9ef2-d6aa0550f620"

fn tft_usd_get()f64 {
	cmc_args := coinmarketcap.CMCNewArgs{secret:CMCKEY}
	mut cmc := coinmarketcap.new(cmc_args)
	price_cmc := cmc.token_price_usd() or {0.0}
	
	liquid_args := liquid.LiquidArgs{secret:CMCKEY}
	mut l := liquid.new(liquid_args)
	price_liquid := l.token_price_usdt() or {0.0}
	
	// retrun the higher value
	if price_liquid > price_cmc {
		return price_liquid
	}
	return price_cmc
}

fn tfprices_varf() map[string]f64 {

	mut varf := map[string]f64{}

	varf["TFTUSD"] = tft_usd_get()
	varf["CU_MUSD"] = 30
	varf["SU_MUSD"] = 15
	varf["NU_MUSD"] = 0.10
	varf["IP_MUSD"] = 5
	varf["NAME_MUSD"] = 1
	varf["DNAME_MUSD"] = 2
	varf["REWARD_CU_USD"] = 16 * 0.15
	varf["REWARD_SU_USD"] = 10 * 0.15
	varf["REWARD_NU_USD"] = 0.2 * 0.15	//is per GB transfer (as customers use it)
	varf["REWARD_IP_USD"] = 0.005 //is per IP address, calculated per hour

	//calculate the dynamic price in TFT
	varf["CU_MTFT"] = varf["CU_MUSD"] / varf["TFTUSD"]
	varf["SU_MTFT"] = varf["SU_MUSD"] / varf["TFTUSD"]
	varf["NU_MTFT"] = varf["NU_MUSD"] / varf["TFTUSD"]
	varf["IP_MTFT"] = varf["IP_MUSD"] / varf["TFTUSD"]
	varf["NAME_MTFT"] = varf["NAME_MUSD"] / varf["TFTUSD"]
	varf["DNAME_MTFT"] = varf["DNAME_MUSD"] / varf["TFTUSD"]

	varf["REWARD_CU_TFT"] = varf["REWARD_CU_USD"] / varf["TFTUSD"]
	varf["REWARD_SU_TFT"] = varf["REWARD_SU_USD"] / varf["TFTUSD"]
	varf["REWARD_NU_TFT"] = varf["REWARD_NU_USD"] / varf["TFTUSD"]
	varf["REWARD_IP_TFT"] = varf["REWARD_IP_USD"] / varf["TFTUSD"]

	return varf

}

fn tfprices_vars() map[string]string{

	now := time.now()

	mut vars := map[string]string{}

	vars["NOW"] = "```"+now.format_ss()+"```"

	return vars

}


fn macro_tfpriceinfo(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	mut out := []string{}

	varf := tfprices_varf()
	vars := tfprices_vars()

	for mut line in state.lines_server{
		for a,b in varf{
			line = line.replace("$"+a,'${b:.2f}')
		}
		for a2,b2 in vars{
			line = line.replace("$"+a2,b2)
		}
	}

	state.changed_server = true

}
