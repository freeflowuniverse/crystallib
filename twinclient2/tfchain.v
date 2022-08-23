module twinclient2
import json



fn new_tfchain(mut client TwinClient) TfChain {
	return TfChain{
		client: unsafe {client}
	}
}

pub fn (mut c TfChain) import_(options TfchainWalletImportModel)?{
	// options: TfchainWalletImportModel{name, mnemonics}
	options_encoded := json.encode(options)
	c.client.send('tfchain.import', "$options_encoded")?
}

pub fn (mut c TfChain) get(options TfchainWalletNameModel)? TfchainWalletAddressModel{
	// options: {name}
	// Returns address as string.
	options_encoded := json.encode(options)
	response := c.client.send('tfchain.get', "$options_encoded")?
	return json.decode(TfchainWalletAddressModel, response.data) or {}
}

pub fn (mut c TfChain) update(options TfchainWalletImportModel)?{
	// options: {name, mnemonics}
	options_encoded := json.encode(options)
	c.client.send('tfchain.update', "$options_encoded")?
}

pub fn (mut c TfChain) exist(options TfchainWalletNameModel)? string{
	// options: {name}
	// Returns bool as string.
	options_encoded := json.encode(options)
	response := c.client.send('tfchain.exist', "$options_encoded")?
	return response.data
}

pub fn (mut c TfChain) list()? []string {
	// Returns array of string.
	response := c.client.send('tfchain.list', "{}")?
	return json.decode([]string, response.data)
}

pub fn (mut c TfChain) balance_by_name(options TfchainWalletNameModel)? BalanceResult {
	// options: {name}
	// Returns BalanceResult{free, feeFrozen, miscFrozen, reserved}
	options_encoded := json.encode(options)
	response := c.client.send('tfchain.balanceByName', "$options_encoded")?
	return json.decode(BalanceResult, response.data)
}

pub fn (mut c TfChain) balance_by_address(options TfchainWalletAddressModel)? BalanceResult {
	// options: {address}
	// Returns BalanceResult{free, feeFrozen, miscFrozen, reserved}
	options_encoded := json.encode(options)
	response := c.client.send('tfchain.balanceByAddress', "$options_encoded")?
	return json.decode(BalanceResult, response.data)
}

pub fn (mut c TfChain) transfer(options TfchainWalletTransferModel)? {
	// options: {"name", "target_address", "amount"}
	options_encoded := json.encode(options)
	c.client.send('tfchain.transfer', "$options_encoded")?
}

pub fn (mut c TfChain) delete(options TfchainWalletNameModel)? {
	// options: {name}
	options_encoded := json.encode(options)
	c.client.send('tfchain.delete', "$options_encoded")?
}
