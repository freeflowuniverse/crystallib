module twinclient2

import json



fn new_balance(mut client TwinClient) Balance {
	// Initialize new tfchain.
	return Balance{
		client: unsafe {client}
	}
}

pub fn (mut blnc Balance) get(address string) ?BalanceResult {
	// Get balance for specific address
	response := blnc.client.send('balance.get', json.encode({"address": address}))?
	return json.decode(BalanceResult, response.data)
}

pub fn (mut blnc Balance) get_my_balance() ?BalanceResult {
	// Get balance for my account
	response := blnc.client.send('balance.getMyBalance', '{}')?
	return json.decode(BalanceResult, response.data)
}

pub fn (mut blnc Balance) transfer(address string, amount f64)?{
	// Transfer balance from my account to specific address
	// This is just workaround for transfer method because in the grid client
	// transfare method exepected receive amount argument as f64 so there is no
	// way to have a map with multiple types so we have a model then we can encode it.
	// Hint: json2.Any used and dont work with json.encode(), server crashes.
	data := BalanceTransfer{
		address: address
		amount: amount
	}
	blnc.client.send('balance.transfer', "${json.encode(data)}")?
}
