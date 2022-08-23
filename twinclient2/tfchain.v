module twinclient2
import json



fn new_tfchain(mut client TwinClient) TfChain {
	return TfChain{
		client: unsafe {client}
	}
}

pub fn (mut c TfChain) import_(name string, mnemonics string)?{
	c.client.send(
		'tfchain.import',
		json.encode({"name": name, "mnemonics": mnemonics})
	)?
}

pub fn (mut c TfChain) get(name string)? TfchainWalletAddressModel{
	// Returns address as string.
	response := c.client.send(
		'tfchain.get',
		json.encode({"name": name})
	)?
	return json.decode(TfchainWalletAddressModel,response.data)
}

pub fn (mut c TfChain) update(name string, mnemonics string)?{
	c.client.send(
		'tfchain.update',
		json.encode({"name": name, "mnemonics": mnemonics})
	)?
}

pub fn (mut c TfChain) exist(name string)? bool{
	response := c.client.send('tfchain.exist', json.encode(
		{"name": name}
	))?
	return response.data.bool()
}

pub fn (mut c TfChain) list()? []string {
	// Returns array of string.
	response := c.client.send('tfchain.list', "{}")?
	return json.decode([]string, response.data)
}

pub fn (mut c TfChain) balance_by_name(name string)? BalanceResult {
	// Returns BalanceResult{free, feeFrozen, miscFrozen, reserved}
	response := c.client.send(
		'tfchain.balanceByName',
		json.encode({"name": name})
	)?
	return json.decode(BalanceResult, response.data)
}

pub fn (mut c TfChain) balance_by_address(address string)? BalanceResult {
	// Returns BalanceResult{free, feeFrozen, miscFrozen, reserved}
	response := c.client.send(
		'tfchain.balanceByAddress', json.encode({"address": address})
	)?
	return json.decode(BalanceResult, response.data)
}

pub fn (mut c TfChain) transfer(name string, target_address string, amount f64)?{
	// This is just workaround for transfer method because in the grid client
	// transfare method exepected receive amount argument as f64 so there is no
	// way to have a map with multiple types so we have a model then we can encode it.
	// Hint: json2.Any used and dont work with json.encode(), server crashes.
	data := TFChainBalanceTransfer{
		name: name,
		target_address: target_address,
		amount: amount
	}
	println("Here")
	// println(json.encode(data))
	c.client.send('tfchain.transfer', "${json.encode(data)}")?
}

pub fn (mut c TfChain) delete(name string)?{
	c.client.send('tfchain.delete', json.encode({"name": name}))?
}
