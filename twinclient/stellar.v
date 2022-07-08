module twinclient

import json

// Import wallet using secret
pub fn (mut tw Client) import_wallet(wallet StellarWallet) ?StellarWallet {
	payload_encoded := json.encode_pretty(wallet)
	mut msg := tw.send('twinserver.stellar.import', payload_encoded)?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return StellarWallet{
		...wallet
		address: response.data
	}
}

// Get wallet using it's name
pub fn (mut tw Client) get_wallet(name string) ?StellarWallet {
	mut get_wallet := StellarWallet{
		name: name
	}
	mut msg := tw.send('twinserver.stellar.get', '{"name": "$name"}')?
	response := tw.read(msg)
	get_wallet.address = response.data
	if response.err != '' {
		return error(response.err)
	}
	return get_wallet
}

// Update imported wallet secret
pub fn (mut tw Client) update_wallet(wallet StellarWallet) ?StellarWallet {
	payload_encoded := json.encode_pretty(wallet)
	mut msg := tw.send('twinserver.stellar.update', payload_encoded)?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return StellarWallet{
		...wallet
		address: response.data
	}
}

// List all imported wallets
pub fn (mut tw Client) list_wallets() ?[]string {
	mut msg := tw.send('twinserver.stellar.list', '{}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]string, response.data) or {}
}

// Get balance using wallet address
pub fn (mut tw Client) balance_by_address(address string) ?[]StellarBalance {
	mut msg := tw.send('twinserver.stellar.balance_by_address', '{"address": $address}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]StellarBalance, response.data) or {}
}

// Get balance using wallet name
pub fn (mut tw Client) balance_by_name(name string) ?[]StellarBalance {
	mut msg := tw.send('twinserver.stellar.balance_by_name', '{"name": "$name"}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]StellarBalance, response.data) or {}
}

// Transfer from wallet to another
pub fn (mut tw Client) stellar_transfer(transfer StellarTransfer) ?string {
	payload_encoded := json.encode_pretty(transfer)
	mut msg := tw.send('twinserver.stellar.transfer', payload_encoded)?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data
}

// Delete wallet using wallet name
pub fn (mut tw Client) delete_wallet(name string) ?bool {
	mut msg := tw.send('twinserver.stellar.delete', '{"name": "$name"}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	if response.data == 'Deleted' {
		return true
	}
	return false
}

// Check if wallet imported before using wallet name
pub fn (mut tw Client) is_wallet_exist(name string) ?bool {
	mut msg := tw.send('twinserver.stellar.exist', '{"name": "$name"}')?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data.bool()
}
