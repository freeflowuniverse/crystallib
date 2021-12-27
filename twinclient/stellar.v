module twinclient

import json

pub fn (mut tw Client) import_wallet(name string, secret string) ?StellarWallet {
	mut imported_wallet := StellarWallet{
		name: name
		secret: secret
	}
	payload_encoded := json.encode_pretty(imported_wallet)
	mut msg := tw.send('twinserver.stellar.import', payload_encoded) ?
	response := tw.read(msg)
	imported_wallet.address = response.data
	if response.err != ''{
		return error(response.err)
	}
	return imported_wallet
}

pub fn (mut tw Client) get_wallet(name string) ?StellarWallet{
	mut get_wallet := StellarWallet{
		name: name
	}
	mut msg := tw.send('twinserver.stellar.get', '{"name": "$name"}') ?
	response := tw.read(msg)
	get_wallet.address = response.data
	if response.err != ''{
		return error(response.err)
	}
	return get_wallet
}

pub fn (mut tw Client) update_wallet(name string, secret string) ?StellarWallet {
	mut update_wallet := StellarWallet{name: name, secret:secret}
	payload_encoded := json.encode_pretty(update_wallet)
	mut msg := tw.send('twinserver.stellar.update', payload_encoded) ?
	response := tw.read(msg)
	update_wallet.address = response.data
	if response.err != ''{
		return error(response.err)
	}
	return update_wallet
}

pub fn (mut tw Client) list_wallets() ?[]string{
	mut msg := tw.send('twinserver.stellar.list', '{}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode([]string, response.data) or {}
}

pub fn (mut tw Client) balance_by_address(address string) ?[]StellarBalance {
	mut msg := tw.send('twinserver.stellar.balance_by_address', '{"address": $address}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode([]StellarBalance, response.data) or {}
}

pub fn (mut tw Client) balance_by_name(name string) ?[]StellarBalance {
	mut msg := tw.send('twinserver.stellar.balance_by_name', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode([]StellarBalance, response.data) or {}
}

pub fn (mut tw Client) stellar_transfer (transfer StellarTransfer) ?string {
	payload_encoded := json.encode_pretty(transfer)
	mut msg := tw.send('twinserver.stellar.transfer', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return response.data
}

pub fn (mut tw Client) delete_wallet (name string) ?bool {
	mut msg := tw.send('twinserver.stellar.delete', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	if response.data == "Deleted"{
		return true
	}
	return false
}

pub fn (mut tw Client) is_wallet_exist(name string) ?bool {
	mut msg := tw.send('twinserver.stellar.exist', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return response.data.bool()
}