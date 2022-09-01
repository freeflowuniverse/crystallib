module twinclient2
import json



fn new_algorand(mut client TwinClient) Algorand {
	return Algorand{
		client: unsafe {client}
	}
}

pub fn (mut alg Algorand) list()? []BlockChainModel {
	response := alg.client.send('algorand.list', "{}")?
	return json.decode([]BlockChainModel, response.data)
}

pub fn (mut alg Algorand) exist(name string)? bool{
	data := NameModel{name: name}
	response := alg.client.send('algorand.exist', json.encode(data).str())?
	return response.data.bool()
}

pub fn (mut alg Algorand) delete(name string)?bool{
	data := NameModel{name: name}
	response := alg.client.send('algorand.delete', json.encode(data).str())?
	if response.data == "Deleted" {
		return true
	} else {
		return false
	}
}

pub fn (mut alg Algorand)create(name string)? BlockChainCreateModel{
	data := NameModel{name: name}
	response := alg.client.send('algorand.create', json.encode(data).str())?
	return json.decode(BlockChainCreateModel, response.data)
}

pub fn (mut alg Algorand)init(name string, secret string)? NameAddressMnemonicModel{
	data := NameSecretModel{
		name: name, secret: secret
	}
	response := alg.client.send(
		'algorand.init',
		json.encode(json.encode(data).str())
	)?
	return json.decode(NameAddressMnemonicModel, response.data)
}

pub fn (mut alg Algorand)assets(name string)?BlockChainAssetsModel{
	data := NameModel{name: name}
	response := alg.client.send('algorand.assets', json.encode(data).str())?
	return json.decode(BlockChainAssetsModel, response.data)
}

pub fn (mut alg Algorand)assets_by_address(address string)?AssetsModel{
	data := AddressModel{address: address}
	response := alg.client.send(
		'algorand.assetsByAddress',
		json.encode(data).str()
	)?
	return json.decode(AssetsModel, response.data)
}

pub fn (mut alg Algorand)get(name string)?BlockChainCreateModel{
	data := NameModel{name: name}
	response := alg.client.send(
		'algorand.get', json.encode(data).str()
	)?
	return json.decode(BlockChainCreateModel, response.data)
}

pub fn (mut alg Algorand)sign(name string, content string)? AlgorandAccountSignBytesResponse{
	data := BlockchainSignModel{name: name, content: content}
	response := alg.client.send('algorand.signBytes',json.encode(data).str())?
	return json.decode(AlgorandAccountSignBytesResponse, response.data)
}

pub fn (mut alg Algorand)pay(name string, address_dest string, amount f64, description string )?{
	data := AlgorandPayModel{
		name: name,
		address_dest: address_dest,
		amount: amount,
		description: description
	}
	println(json.encode(data).str())
	response := alg.client.send('algorand.pay', json.encode(data).str())?
	println(response.data)
	// x := json.decode(AlgorandPayResponseModel, response.data)?
}