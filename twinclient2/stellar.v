module twinclient2

import json


fn new_stellar(mut client TwinClient) Stellar {
	// Initialize new stellar.
	return Stellar{
		client: unsafe {client}
	}
}

pub fn (mut st Stellar)create(name string)?BlockChainCreateModel{
	data := NameModel{name: name}
	response := st.client.send('stellar.create', json.encode(data).str())?
	return json.decode(BlockChainCreateModel, response.data)
}

pub fn (mut st Stellar)sign(name string, content string)? BlockChainSignResponseModel{
	data := BlockchainSignModel{name: name, content: content}
	response := st.client.send('stellar.sign', json.encode(data).str())?
	return json.decode(BlockChainSignResponseModel, response.data)
}

pub fn (mut st Stellar)init(name string, secret string) ?string {
	// Returns pub key.
	data := NameSecretModel{name: name, secret: secret}
	response := st.client.send('stellar.init', json.encode(data).str())?
	return response.data
}

pub fn (mut st Stellar)get(name string) ?StellarWallet {
	data := NameModel{name: name}
	response := st.client.send('stellar.get', json.encode(data).str())?
	return json.decode(StellarWallet, response.data)
}

pub fn (mut st Stellar)update(name string, secret string)?NameSecretModel{
	data := NameSecretModel{name: name, secret: secret}
	st.client.send('stellar.update', json.encode(data).str())?
	return data
}

pub fn (mut st Stellar)list()?[]BlockChainModel {
	response := st.client.send('stellar.list', "{}")?
	return json.decode([]BlockChainModel, response.data)
}

pub fn (mut st Stellar)assets(name string)?BlockChainAssetsModel{
	data := NameModel{name: name}
	response := st.client.send('stellar.assets', json.encode(data).str())?
	return json.decode(BlockChainAssetsModel, response.data)
}

pub fn (mut st Stellar)balance_by_address(address string) ?[]StellarBalance {
	data := AddressModel{address: address}
	response := st.client.send('stellar.balance_by_address', json.encode(data).str())?
	return json.decode([]StellarBalance, response.data)
}

pub fn (mut st Stellar)pay(name string, address_dest string, 
	amount f64, asset string,
	description string
	)?string{
	data := StellarPayModel{
		name: name,
		address_dest: address_dest,
		amount: amount,
		asset: asset,
		description: description
	}
	response := st.client.send('stellar.pay', json.encode(data).str())?
	return response.data
}

pub fn (mut st Stellar)delete(name string)?bool{
	data := NameModel{name: name}
	response := st.client.send('stellar.delete', json.encode(data).str())?
	if response.data == 'Deleted' {
		return true
	}
	return false
}

pub fn (mut st Stellar) exist(name string) ?bool {
	data := NameModel{name: name}
	response := st.client.send('stellar.exist', json.encode(data).str())?
	return response.data.bool()
}
