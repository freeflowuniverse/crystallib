module twinclient

import json


// Create new node contract
pub fn (mut client TwinClient) contracts_create_node(payload NodeContractCreate) !Contract {
	payload_encoded := json.encode_pretty(payload)
	response := client.transport.send('contracts.create_node', payload_encoded)!

	return json.decode(Contract, response.data)
}

// Create new name contract
pub fn (mut client TwinClient) contracts_create_name(name string) !Contract {
<<<<<<< HEAD
	response := client.transport.send('contracts.create_name', json.encode({"name": name}))?
=======
	response := client.transport.send('contracts.create_name', json.encode({"name": name}))!
>>>>>>> 9e6b7a0d88f2e847f543d4e8540b4a36eab677bf

	return json.decode(Contract, response.data)
}

// Get contract by specific Id
pub fn (mut client TwinClient) contracts_get(id u64) !Contract {
<<<<<<< HEAD
	response := client.transport.send('contracts.get', json.encode({"id": id}))?
=======
	response := client.transport.send('contracts.get', json.encode({"id": id}))!
>>>>>>> 9e6b7a0d88f2e847f543d4e8540b4a36eab677bf

	return json.decode(Contract, response.data)
}

// Get contract id from node_id and hash
pub fn (mut client TwinClient) contracts_get_contract_id_by_node_id_and_hash(payload ContractIdByNodeIdAndHash) !u64 {
	payload_encoded := json.encode_pretty(payload)
	response := client.transport.send('contracts.get_contract_id_by_node_id_and_hash', payload_encoded)!

	return response.data.u64()
}

// Get name contract by specific name
pub fn (mut client TwinClient) contracts_get_name_contract(name string) !u64 {
	response := client.transport.send('contracts.get_name_contract', json.encode({"name": name}))!

	return response.data.u64()
}

// Update contract hash and data using contract id
pub fn (mut client TwinClient) contracts_update_node_contract(payload NodeContractUpdate) !Contract {
	payload_encoded := json.encode_pretty(payload)
	response := client.transport.send('contracts.update_node', payload_encoded)!

	return json.decode(Contract, response.data)
}

// Cancel contract using contract_id
pub fn (mut client TwinClient) contracts_cancel(id u64) !u64 {
	response := client.transport.send('contracts.cancel', json.encode({"id": id}))!

	return response.data.u64()
}

// List all my contracts
pub fn (mut client TwinClient) contracts_list_my_contracts() !ListContracts {
<<<<<<< HEAD
	response := client.transport.send('contracts.listMyContracts', '{}')?
=======
	response := client.transport.send('contracts.listMyContracts', '{}')!
>>>>>>> 9e6b7a0d88f2e847f543d4e8540b4a36eab677bf

	return json.decode(ListContracts, response.data)
}

// List all contracts for specific twin_id
pub fn (mut client TwinClient) contracts_list_contracts_by_twin_id(twin_id u32) !ListContracts {
<<<<<<< HEAD
	response := client.transport.send('contracts.listContractsByTwinId', json.encode({"twinId": twin_id}))?
=======
	response := client.transport.send('contracts.listContractsByTwinId', json.encode({"twinId": twin_id}))!
>>>>>>> 9e6b7a0d88f2e847f543d4e8540b4a36eab677bf

	return json.decode(ListContracts, response.data)
}

// List all contracts for specific address
pub fn (mut client TwinClient) contracts_list_contracts_by_address(address string) !ListContracts {
<<<<<<< HEAD
	response := client.transport.send('contracts.listContractsByAddress', json.encode({"address": address}))?
=======
	response := client.transport.send('contracts.listContractsByAddress', json.encode({"address": address}))!
>>>>>>> 9e6b7a0d88f2e847f543d4e8540b4a36eab677bf

	return json.decode(ListContracts, response.data)
}

// Cancel all my contracts
pub fn (mut client TwinClient) contracts_cancel_my_contracts() ![]SimpleContract {
<<<<<<< HEAD
	response := client.transport.send('contracts.cancelMyContracts', '{}')?
=======
	response := client.transport.send('contracts.cancelMyContracts', '{}')!
>>>>>>> 9e6b7a0d88f2e847f543d4e8540b4a36eab677bf

	return json.decode([]SimpleContract, response.data)
}

// Get TFT consume for each contract per hour using contract_id
pub fn (mut client TwinClient) contracts_get_consumption(id u64) !f64 {
	response := client.transport.send('contracts.getConsumption', json.encode({"id": id}))!

	return response.data.f64()
}

pub fn (mut client TwinClient) get_deletion_time(id u64)! u64{
	response := client.transport.send('contracts.getDeletionTime', json.encode({"id": id}))!
	return response.data.u64()
}
