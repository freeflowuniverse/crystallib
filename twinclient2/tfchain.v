module twinclient2
import json



fn new_tfchain(mut client TwinClient) TfChain {
	return TfChain{
		client: unsafe {client}
	}
}

pub fn (mut c TfChain) import_(options string)?{
	// options: {name, mnemonics}
	c.client.send('tfchain.import', options)?
}

pub fn (mut c TfChain) get(options string)? TfchainWalletAddressModel{
	// options: {name}
	// Returns address as string.
	response := c.client.send('tfchain.get', options)?
	return json.decode(TfchainWalletAddressModel, response.data) or {}
}

pub fn (mut c TfChain) update(options string)?{
	// options: {name, mnemonics}
	c.client.send('tfchain.update', options)?
}

pub fn (mut c TfChain) exist(options string)? string{
	// options: {name}
	// Returns bool as string.
	response := c.client.send('tfchain.exist', options)?
	return response.data
}

pub fn (mut c TfChain) list()? []string {
	// Returns array of string.
	response := c.client.send('tfchain.list', "{}")?
	return json.decode([]string, response.data)
}

pub fn (mut c TfChain) balance_by_name(options string)? BalanceResult {
	// options: {name}
	// Returns BalanceResult{free, feeFrozen, miscFrozen, reserved}
	response := c.client.send('tfchain.balanceByName', options)?
	return json.decode(BalanceResult, response.data)
}

pub fn (mut c TfChain) balance_by_address(options string)? BalanceResult {
	// options: {address}
	// Returns BalanceResult{free, feeFrozen, miscFrozen, reserved}
	response := c.client.send('tfchain.balanceByAddress', options)?
	return json.decode(BalanceResult, response.data)
}

pub fn (mut c TfChain) transfer(options string)? {
	// options: {"name", "target_address", "amount"}
	c.client.send('tfchain.transfer', options)?
}

pub fn (mut c TfChain) delete(options string)? {
	// options: {name}
	c.client.send('tfchain.delete', options)?
}
