module twinclient2
import json



fn new_algorand(mut client TwinClient) Algorand {
	return Algorand{
		client: unsafe {client}
	}
}

pub fn (mut alg Algorand) import_(name string, mnemonic string)? AlgorandAccountImportResponseModel{
	response := alg.client.send(
		'algorand.import',
		json.encode({"name": name, "mnemonic": mnemonic})
	)?
	return json.decode(AlgorandAccountImportResponseModel, response.data)
}

pub fn (mut alg Algorand) get(name string)? AlgorandAccountMnemonicsModel{
	response := alg.client.send(
		'algorand.get', json.encode({"name": name})
	)?
	return json.decode(AlgorandAccountMnemonicsModel, response.data)
}

pub fn (mut alg Algorand) sign_bytes(name string, msg string)? AlgorandAccountSignBytesResponse{
	response := alg.client.send(
		'algorand.signBytes',
		json.encode({"name": name, "msg": msg})
	)?
	return json.decode(AlgorandAccountSignBytesResponse, response.data)
}

pub fn (mut alg Algorand) assets_by_name(name string)? string{
	response := alg.client.send(
		'algorand.assetsByName', 
		json.encode({"name": name})
	)?
	return response.data
}

pub fn (mut alg Algorand) assets_by_address(address string)? string{
	response := alg.client.send(
		'algorand.assetsByAddress', 
		json.encode({"address": address})
	)?
	return response.data
}

pub fn (mut alg Algorand) exist(name string)? bool{
	response := alg.client.send('algorand.exist', json.encode({"name": name}))?
	return response.data.bool()
}

pub fn (mut alg Algorand) list()? []string {
	// Returns array of string.
	response := alg.client.send('algorand.list', "{}")?
	return json.decode([]string, response.data)
}

pub fn (mut alg Algorand) delete(name string)?{
	alg.client.send('algorand.delete', json.encode({"name": name}))?
}

pub fn (mut alg Algorand) create(name string)? {
	alg.client.send('algorand.create', json.encode({"name": name}))?
}

pub fn (mut alg Algorand) transfer(sender string, receiver string, amount f64, text string)? {
	data := AlgorandBalanceTransfer{
		sender: sender,
		receiver: receiver,
		amount: amount,
		text: text,
	}
	alg.client.send('algorand.transfer', "${json.encode(data)}")?
}