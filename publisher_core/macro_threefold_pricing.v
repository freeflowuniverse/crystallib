module publisher_core

import coinmarketcap
import liquid
import time
import texttools

const cmckey = "92be9b29-7f6c-48e4-9ef2-d6aa0550f620"

fn tft_usd_get()f64 {
	cmc_args := coinmarketcap.CMCNewArgs{secret:cmckey}
	mut cmc := coinmarketcap.new(cmc_args)
	price_cmc := cmc.token_price_usd() or {0.0}
	
	liquid_args := liquid.LiquidArgs{secret:cmckey}
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
	varf["TFTFARMING"] = 0.08
	varf["CU_USD_MONTH"] = 20
	varf["SU_USD_MONTH"] = 12
	varf["IP_USD_MONTH"] = 4
	varf["NU_USD_GB"] = 0.05 //price per GB
	varf["NAME_USD_MONTH"] = 1
	varf["DNAME_USD_MONTH"] = 2
	varf["REWARD_CU_USD"] = 2.4
	varf["REWARD_SU_USD"] = 1
	varf["REWARD_NU_USD"] = 0.03	//is per GB transfer (as customers use it)
	varf["REWARD_IP_USD"] = 0.005 //is per IP address, calculated per hour

	//calculate mUSD per hour
	varf["CU_MUSD_HOUR"] = (varf["CU_USD_MONTH"]*1000)/(30*24)
	varf["SU_MUSD_HOUR"] = (varf["SU_USD_MONTH"]*1000)/(30*24)
	varf["NU_MUSD_GB"] = (varf["NU_USD_GB"]*1000)
	varf["IP_MUSD_HOUR"] = (varf["IP_USD_MONTH"]*1000)/(30*24)
	varf["NAME_MUSD_HOUR"] = (varf["NAME_USD_MONTH"]*1000)/(30*24)
	varf["DNAME_MUSD_HOUR"] = (varf["DNAME_USD_MONTH"]*1000)/(30*24)

	//calculate the dynamic price in TFT
	varf["CU_MTFT_HOUR"] = varf["CU_MUSD_HOUR"] / varf["TFTUSD"]
	varf["SU_MTFT_HOUR"] = varf["SU_MUSD_HOUR"] / varf["TFTUSD"]
	varf["NU_MTFT_GB"] = varf["NU_MUSD_GB"] / varf["TFTUSD"]
	varf["IP_MTFT_HOUR"] = varf["IP_MUSD_HOUR"] / varf["TFTUSD"]
	varf["NAME_MTFT_HOUR"] = varf["NAME_MUSD_HOUR"] / varf["TFTUSD"]
	varf["DNAME_MTFT_HOUR"] = varf["DNAME_MUSD_HOUR"] / varf["TFTUSD"]


	//calculate the dynamic price in USD per month after discount
	varf["CU_USD_MONTH_DISCOUNT"] = varf["CU_USD_MONTH"] * 0.4 
	varf["SU_USD_MONTH_DISCOUNT"] = varf["SU_USD_MONTH"] * 0.4 
	varf["NU_USD_MONTH_DISCOUNT"] = varf["NU_USD_GB"] * 0.6 
	varf["IP_USD_MONTH_DISCOUNT"] = varf["IP_USD_MONTH"] * 0.6 	

	
	varf["REWARD_CU_TFT"] = varf["REWARD_CU_USD"] / varf["TFTFARMING"]
	varf["REWARD_SU_TFT"] = varf["REWARD_SU_USD"] / varf["TFTFARMING"]
	varf["REWARD_NU_TFT"] = varf["REWARD_NU_USD"] / varf["TFTFARMING"]
	varf["REWARD_IP_TFT"] = varf["REWARD_IP_USD"] / varf["TFTFARMING"]

	return varf

}

fn tfprices_vars() map[string]string{

	now := time.now()

	mut vars := map[string]string{}

	vars["NOW"] = "```"+now.format_ss()+"```"

	return vars

}


fn macro_tfpriceinfo(mut state LineProcessorState, mut macro texttools.MacroObj) ? {
	// mut out := []string{}

	varf := tfprices_varf()
	vars := tfprices_vars()

	mut fkeys := varf.keys()
	mut skeys := vars.keys()
	fkeys.sort()
	fkeys.reverse_in_place()
	skeys.sort()
	skeys.reverse_in_place()

	for mut line in state.lines_server{
		for a in fkeys{
			b := varf[a]
			line = line.replace("$"+a,'${b:.2f}')
		}
		for a2 in skeys{
			b2 := vars[a2]
			line = line.replace("$"+a2,b2)
		}
	}

	state.changed_server = true

}
