module twinclient2

import json


fn new_stellar(mut client TwinClient) Stellar {
	// Initialize new stellar.
	return Stellar{
		client: unsafe {client}
	}
}


pub fn (mut st Stellar) import_(name string, mnemonics string) ?StellarWallet {
	// Import wallet using secret.
	response := st.client.send(
		'stellar.import', 
		json.encode(
			{
				"name": name,
				"mnemonics": mnemonics
			}
		)
	)?
	return json.decode(StellarWallet, response.data)
}

pub fn (mut st Stellar) get(name string) ?StellarWallet {
	// Get wallet using it's name.
	response := st.client.send('stellar.get', json.encode({"name": name}))?
	return json.decode(StellarWallet, response.data)
}

pub fn (mut st Stellar) update(name string, secret string)?string{
	// Update imported wallet secret
	response := st.client.send(
		'stellar.update', 
		json.encode(
			{
				"name": name,
				"secret": secret
			}
		)
	)?
	return response.data
	// return StellarWallet{
	// 	...wallet
	// 	address: response.data
	// }
}

pub fn (mut st Stellar) list() ?[]string {
	// List all imported wallets
	response := st.client.send('stellar.list', '{}')?
	return json.decode([]string, response.data)
}

pub fn (mut st Stellar) balance_by_address(address string) ?[]StellarBalance {
	// Get balance using wallet address
	response := st.client.send(
		'stellar.balance_by_address', 
		json.encode({"address": address})
	)?
	return json.decode([]StellarBalance, response.data)
}

pub fn (mut st Stellar) balance_by_name(name string) ?[]StellarBalance {
	// Get balance using wallet name
	response := st.client.send(
		'stellar.balance_by_name',
		json.encode({"name": name})
	)?
	return json.decode([]StellarBalance, response.data)
}

pub fn (mut st Stellar) transfer(transfer StellarTransfer) ?string {
	// Transfer from wallet to another
	payload_encoded := json.encode_pretty(transfer)
	response := st.client.send('stellar.transfer', payload_encoded)?
	return response.data
}

pub fn (mut st Stellar) delete(name string) ?bool {
	// Delete wallet using wallet name
	response := st.client.send('stellar.delete', '{"name": "$name"}')?
	if response.data == 'Deleted' {
		return true
	}
	return false
}

pub fn (mut st Stellar) exist(name string) ?bool {
	// Check if wallet imported before using wallet name
	response := st.client.send('stellar.exist', '{"name": "$name"}')?
	return response.data.bool()
}
