module twinclient2
import json



pub fn (mut client TwinClient) tfchain_init(name string, secret string)?NameSecretModel{
	data := NameSecretModel{name: name, secret: secret}
	client.send('tfchain.init', json.encode(data).str())?
	return data
}

pub fn (mut client TwinClient) tfchain_get(name string)?BlockChainModel{
	data := NameModel{name: name}
	response := client.send('tfchain.get', json.encode(data).str())?
	return json.decode(BlockChainModel, response.data)
}

pub fn (mut client TwinClient) tfchain_update(name string, secret string)?NameSecretModel{
	data := NameSecretModel{name: name, secret: secret}
	client.send('tfchain.update', json.encode(data).str())?
	return data
}

pub fn (mut client TwinClient) tfchain_exist(name string)?bool{
	data := NameModel{name: name}
	response := client.send('tfchain.exist', json.encode(data).str())?
	return response.data.bool()
}

pub fn (mut client TwinClient) tfchain_list()?[]BlockChainModel {
	response := client.send('tfchain.list', "{}")?
	return json.decode([]BlockChainModel, response.data)
}

pub fn (mut client TwinClient) tfchain_balance_by_address(address string)?BalanceResult{
	data := AddressModel{address: address}
	response := client.send('tfchain.balanceByAddress', json.encode(data).str())?
	return json.decode(BalanceResult, response.data)
}

pub fn (mut client TwinClient) tfchain_assets(address string)?BlockChainAssetsModel{
	data := AddressModel{address: address}
	response := client.send('tfchain.assets', json.encode(data).str())?
	return json.decode(BlockChainAssetsModel, response.data)
}

pub fn (mut client TwinClient) tfchain_create(name string, ip string)? BlockChainCreateModel{
	data := NameIPModel{name: name, ip: ip}
	response := client.send('tfchain.create', json.encode(data).str())?
	return json.decode(BlockChainCreateModel, response.data)
}

pub fn (mut client TwinClient) tfchain_pay(name string, target_address string, amount f64)?{
	data := TFChainPayModel{
		name: name,
		target_address: target_address,
		amount: amount
	}
	client.send('tfchain.pay', json.encode(data).str())?
}

pub fn (mut client TwinClient) tfchain_sign(name string, content string)?{
	data := BlockChainSignModel{
		name: name,
		content: content
	}
	client.send('tfchain.sign', json.encode(data).str())?
	// return TFChainPayModel
}

pub fn (mut client TwinClient) tfchain_delete(name string)?bool{
	data := NameModel{name: name}
	response := client.send('tfchain.delete', json.encode(data).str())?
	if response.data == "Deleted" {
		return true
	}
	return false
}
