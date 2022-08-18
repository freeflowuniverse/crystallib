module twinclient2

import json

// Get balance for specific address
pub fn (mut tw TwinClient) get_balance(address string) ?BalanceResult {
	response := tw.send('balance.get', '{"address": "$address"}')?
	return json.decode(BalanceResult, response.data) or {}
}

// Get balance for my account
pub fn (mut tw TwinClient) get_my_balance() ?BalanceResult {
	response := tw.send('balance.getMyBalance', '{}')?
	return json.decode(BalanceResult, response.data) or {}
}

// // Transfer balance from my account to specific address
// pub fn (mut tw TwinClient) transfer_balance(address string, amount u64) ?u64 {
// 	response := tw.send('balance.transfer', '{"address": "$address", "amount": $amount}')?
// 	println(response)
// 	// return json.decode(DeployResponse, response.data) or {}
// }
