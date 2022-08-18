module twinclient2

import json

// Create new node contract
pub fn (mut tw TwinClient) create_node_contract(payload NodeContractCreate) ?Contract {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('contracts.create_node', payload_encoded)?

	return json.decode(Contract, response.data) or {}
}

// Create new name contract
pub fn (mut tw TwinClient) create_name_contract(name string) ?Contract {
	response := tw.send('contracts.create_name', '{"name": "$name"}')?

	return json.decode(Contract, response.data) or {}
}

// Get contract by specific Id
pub fn (mut tw TwinClient) get_contract(id u64) ?Contract {
	response := tw.send('contracts.get', '{"id": $id}')?

	return json.decode(Contract, response.data) or {}
}

// Get contract id from node_id and hash
pub fn (mut tw TwinClient) get_contract_id_by_node_and_hash(payload ContractIdByNodeIdAndHash) ?u64 {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('contracts.get_contract_id_by_node_id_and_hash', payload_encoded)?

	return response.data.u64()
}

// Get name contract by specific name
pub fn (mut tw TwinClient) get_name_contract(name string) ?u64 {
	response := tw.send('contracts.get_name_contract', '{"name": "$name"}')?

	return response.data.u64()
}

// Update contract hash and data using contract id
pub fn (mut tw TwinClient) update_node_contract(payload NodeContractUpdate) ?Contract {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('contracts.update_node', payload_encoded)?

	return json.decode(Contract, response.data) or {}
}

// Cancel contract using contract_id
pub fn (mut tw TwinClient) cancel_contract(id u64) ?u64 {
	response := tw.send('contracts.cancel', '{"id": $id}')?

	return response.data.u64()
}

// List all my contracts
pub fn (mut tw TwinClient) list_my_contracts() ?ListContracts {
	response := tw.send('contracts.listMyContracts', '{}')?

	return json.decode(ListContracts, response.data) or {}
}

// List all contracts for specific twin_id
pub fn (mut tw TwinClient) list_contracts_by_twin_id(twin_id u32) ?ListContracts {
	response := tw.send('contracts.listContractsByTwinId', '{"twinId": $twin_id}')?

	return json.decode(ListContracts, response.data) or {}
}

// List all contracts for specific address
pub fn (mut tw TwinClient) list_contracts_by_address(address string) ?ListContracts {
	response := tw.send('contracts.listContractsByAddress', '{"address": "$address"}')?

	return json.decode(ListContracts, response.data) or {}
}

// Cancel all my contracts
pub fn (mut tw TwinClient) cancel_my_contracts() ?[]SimpleContract {
	response := tw.send('contracts.cancelMyContracts', '{}')?

	return json.decode([]SimpleContract, response.data) or {}
}

// Get TFT consume for each contract per hour using contract_id
pub fn (mut tw TwinClient) get_consumption(id u64) ?f64 {
	response := tw.send('contracts.getConsumption', '{"id": $id}')?

	return response.data.f64()
}
