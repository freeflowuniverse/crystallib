module twinclient2
import json



fn new_tfchain(mut client TwinClient)TfChain{
	return TfChain{client: unsafe {client}}
}

pub fn (mut c TfChain)init(name string, secret string)?NameSecretModel{
	data := NameSecretModel{name: name, secret: secret}
	c.client.send('tfchain.init', json.encode(data).str())?
	return data
}

pub fn (mut c TfChain)get(name string)?BlockChainModel{
	data := NameModel{name: name}
	response := c.client.send('tfchain.get', json.encode(data).str())?
	return json.decode(BlockChainModel, response.data)
}

pub fn (mut c TfChain)update(name string, secret string)?NameSecretModel{
	data := NameSecretModel{name: name, secret: secret}
	c.client.send('tfchain.update', json.encode(data).str())?
	return data
}

pub fn (mut c TfChain)exist(name string)?bool{
	data := NameModel{name: name}
	response := c.client.send('tfchain.exist', json.encode(data).str())?
	return response.data.bool()
}

pub fn (mut c TfChain)list()?[]BlockChainModel {
	response := c.client.send('tfchain.list', "{}")?
	return json.decode([]BlockChainModel, response.data)
}

pub fn (mut c TfChain)balance_by_address(address string)?BalanceResult{
	data := AddressModel{address: address}
	response := c.client.send('tfchain.balanceByAddress', json.encode(data).str())?
	return json.decode(BalanceResult, response.data)
}

pub fn (mut c TfChain)assets(address string)?BlockChainAssetsModel{
	data := AddressModel{address: address}
	response := c.client.send('tfchain.assets', json.encode(data).str())?
	return json.decode(BlockChainAssetsModel, response.data)
}

pub fn (mut c TfChain)create(name string, ip string)? BlockChainCreateModel{
	data := NameIPModel{name: name, ip: ip}
	response := c.client.send('tfchain.create', json.encode(data).str())?
	return json.decode(BlockChainCreateModel, response.data)
}

pub fn (mut c TfChain)pay(name string, target_address string, amount f64)?{
	data := TFChainPayModel{
		name: name,
		target_address: target_address,
		amount: amount
	}
	c.client.send('tfchain.pay', json.encode(data).str())?
}

pub fn (mut c TfChain)sign(name string, content string)?{
	data := BlockChainSignModel{
		name: name,
		content: content
	}
	c.client.send('tfchain.sign', json.encode(data).str())?
	// return TFChainPayModel
}

pub fn (mut c TfChain) delete(name string)?bool{
	data := NameModel{name: name}
	response := c.client.send('tfchain.delete', json.encode(data).str())?
	if response.data == "Deleted" {
		return true
	} else {
		return false
	}
}
