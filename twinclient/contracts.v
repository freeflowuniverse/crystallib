module twinclient

import json

// Create new node contract
pub fn (mut tw Client) create_node_contract(payload NodeContractCreate) ?Contract {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.contracts.create_node', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(Contract, response.data) or {}
}

// Create new name contract
pub fn (mut tw Client) create_name_contract(name string) ?Contract {
	mut msg := tw.send('twinserver.contracts.create_name', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(Contract, response.data) or {}
}

// Get contract by specific Id
pub fn (mut tw Client) get_contract(id u64) ?Contract {
	mut msg := tw.send('twinserver.contracts.get', '{"id": $id}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(Contract, response.data) or {}
}

// Get contract id from node_id and hash
pub fn (mut tw Client) get_contract_id_by_node_and_hash(payload ContractIdByNodeIdAndHash) ?u64 {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.contracts.get_contract_id_by_node_id_and_hash', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data.u64()
}

// Get name contract by specific name
pub fn (mut tw Client) get_name_contract(name string) ?u64 {
	mut msg := tw.send('twinserver.contracts.get_name_contract', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data.u64()
}

// Update contract hash and data using contract id
pub fn (mut tw Client) update_node_contract(payload NodeContractUpdate) ?Contract {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.contracts.update_node', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(Contract, response.data) or {}
}

// Cancel contract using contract_id
pub fn (mut tw Client) cancel_contract(id u64) ?u64 {
	mut msg := tw.send('twinserver.contracts.cancel', '{"id": $id}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data.u64()
}

// List all my contracts
pub fn (mut tw Client) list_my_contracts() ?ListContracts {
	mut msg := tw.send('twinserver.contracts.listMyContracts', '{}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(ListContracts, response.data) or {}
}

// List all contracts for specific twin_id
pub fn (mut tw Client) list_contracts_by_twin_id(twin_id u32) ?ListContracts {
	mut msg := tw.send('twinserver.contracts.listContractsByTwinId', '{"twinId": $twin_id}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(ListContracts, response.data) or {}
}

// List all contracts for specific address
pub fn (mut tw Client) list_contracts_by_address(address string) ?ListContracts {
	mut msg := tw.send('twinserver.contracts.listContractsByAddress', '{"address": "$address"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(ListContracts, response.data) or {}
}

// Cancel all my contracts
pub fn (mut tw Client) cancel_my_contracts() ?[]SimpleContract {
	mut msg := tw.send('twinserver.contracts.cancelMyContracts', '{}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]SimpleContract, response.data) or {}
}

// Get TFT consume for each contract per hour using contract_id
pub fn (mut tw Client) get_consumption(id u64) ?f64 {
	mut msg := tw.send('twinserver.contracts.getConsumption', '{"id": $id}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return response.data.f64()
}
