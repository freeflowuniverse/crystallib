module twinclient

import json

pub fn (mut tw Client) create_node_contract(node_id u32, hash string, data string, public_ip u32) ?Contract {
	/*
	Create new contract
		Input:
			- node_id (u32): zos node id
			- hash (string): deployment challenge hash
			- data (string): deployment data
			- public_ip (u32): nutwer of public IPs
		Output:
			- Contract: new Contract instance with all contract info.
	*/
	mut msg := tw.send('twinserver.contracts.create_node', '{"node_id": $node_id, "hash": "$hash", "data": "$data", "public_ip": $public_ip}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(Contract, response.data) or {}
}

pub fn (mut tw Client) get_contract(id u64) ?Contract {
	/*
	Get contract info with id
		Input:
			- id: contract id
		Output:
			- Contract: Contract instance with all contract info.
	*/
	mut msg := tw.send('twinserver.contracts.get', '{"id": $id}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(Contract, response.data) or {}
}

pub fn (mut tw Client) update_node_contract(id u64, hash string, data string) ?Contract {
	/*
	Update contract hash and data using contract id
		Input:
			- id: contract id
			- hash: new deployment challenge hash
			- date: new deployment data
		Output:
			- Contract: Contract instance with all contract info after update.
	*/
	mut msg := tw.send('twinserver.contracts.update_node', '{"id": $id, "hash": "$hash", "data": "$data"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(Contract, response.data) or {}
}

pub fn (mut tw Client) cancel_contract(id u64) ?u64 {
	/*
	Cancel contract
		Input:
			- id: contract id
		Output:
			- canceled id: return the cancled contract id
	*/
	mut msg := tw.send('twinserver.contracts.cancel', '{"id": $id}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return response.data.u64()
}
