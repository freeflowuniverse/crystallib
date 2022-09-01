module twinclient2
import json



fn new_tfchain(mut client TwinClient)TfChain{
	return TfChain{client: unsafe {client}}
}

pub fn (mut c TfChain)init(name string, secret string)?NameSecretModel{
	data := NameSecretModel{name: name, secret: secret}
	c.client.send('tfchain.init', "${json.encode(data)}")?
	return data
}

pub fn (mut c TfChain)get(name string)?TfChainCreateModel{
	data := NameModel{name: name}
	response := c.client.send('tfchain.get', "${json.encode(data)}")?
	return json.decode(TfChainCreateModel, response.data)
}

pub fn (mut c TfChain)update(name string, secret string)?NameSecretModel{
	data := NameSecretModel{name: name, secret: secret}
	c.client.send('tfchain.update', "${json.encode(data)}")?
	return data
}

pub fn (mut c TfChain)exist(name string)?bool{
	data := NameModel{name: name}
	response := c.client.send('tfchain.exist', "${json.encode(data)}")?
	return response.data.bool()
}

pub fn (mut c TfChain)list()?[]TfChainCreateModel {
	response := c.client.send('tfchain.list', "{}")?
	return json.decode([]TfChainCreateModel, response.data)
}

pub fn (mut c TfChain)balance_by_address(address string)?BalanceResult{
	data := AddressModel{address: address}
	response := c.client.send('tfchain.balanceByAddress', "${json.encode(data)}")?
	return json.decode(BalanceResult, response.data)
}

pub fn (mut c TfChain)assets(address string)?TFChainAssetsModel{
	data := AddressModel{address: address}
	response := c.client.send('tfchain.assets', "${json.encode(data)}")?
	return json.decode(TFChainAssetsModel, response.data)
}

pub fn (mut c TfChain)create(name string, ip string)? TfChainCreateModel{
	data := NameIPModel{name: name, ip: ip}
	response := c.client.send('tfchain.create', "${json.encode(data)}")?
	return json.decode(TfChainCreateModel, response.data)
}

pub fn (mut c TfChain)pay(name string, target_address string, amount f64)?{
	data := TFChainPay{
		name: name,
		target_address: target_address,
		amount: amount
	}
	c.client.send('tfchain.pay', "${json.encode(data)}")?
}

pub fn (mut c TfChain)sign(name string, content string)?{
	data := BlockChainSignModel{
		name: name,
		content: content
	}
	c.client.send('tfchain.sign', "${json.encode(data)}")?
	// return TFChainPay
}

pub fn (mut c TfChain) delete(name string)? string{
	c.client.send('tfchain.delete', json.encode({"name": name}))?
	return "Deleted"
}
