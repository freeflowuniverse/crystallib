module twinclient2

import json

// Import wallet using secret
pub fn (mut tw TwinClient) import_wallet(wallet StellarWallet) ?StellarWallet {
	payload_encoded := json.encode_pretty(wallet)
	response := tw.send('stellar.import', payload_encoded)?

	return StellarWallet{
		...wallet
		address: response.data
	}
}

// Get wallet using it's name
pub fn (mut tw TwinClient) get_wallet(name string) ?StellarWallet {
	mut get_wallet := StellarWallet{
		name: name
	}
	response := tw.send('stellar.get', '{"name": "$name"}')?

	get_wallet.address = response.data

	return get_wallet
}

// Update imported wallet secret
pub fn (mut tw TwinClient) update_wallet(wallet StellarWallet) ?StellarWallet {
	payload_encoded := json.encode_pretty(wallet)
	response := tw.send('stellar.update', payload_encoded)?

	return StellarWallet{
		...wallet
		address: response.data
	}
}

// List all imported wallets
pub fn (mut tw TwinClient) list_wallets() ?[]string {
	response := tw.send('stellar.list', '{}')?

	return json.decode([]string, response.data) or {}
}

// Get balance using wallet address
pub fn (mut tw TwinClient) balance_by_address(address string) ?[]StellarBalance {
	response := tw.send('stellar.balance_by_address', '{"address": $address}')?

	return json.decode([]StellarBalance, response.data) or {}
}

// Get balance using wallet name
pub fn (mut tw TwinClient) balance_by_name(name string) ?[]StellarBalance {
	response := tw.send('stellar.balance_by_name', '{"name": "$name"}')?

	return json.decode([]StellarBalance, response.data) or {}
}

// Transfer from wallet to another
pub fn (mut tw TwinClient) stellar_transfer(transfer StellarTransfer) ?string {
	payload_encoded := json.encode_pretty(transfer)
	response := tw.send('stellar.transfer', payload_encoded)?

	return response.data
}

// Delete wallet using wallet name
pub fn (mut tw TwinClient) delete_wallet(name string) ?bool {
	response := tw.send('stellar.delete', '{"name": "$name"}')?

	if response.data == 'Deleted' {
		return true
	}
	return false
}

// Check if wallet imported before using wallet name
pub fn (mut tw TwinClient) is_wallet_exist(name string) ?bool {
	response := tw.send('stellar.exist', '{"name": "$name"}')?

	return response.data.bool()
}
