module twinclient2

import json


pub fn (mut client TwinClient) zdb_deploy(payload ZDBs) ?DeployResponse {
	// Deploy zdbs workload
	payload_encoded := json.encode_pretty(payload)
	response := client.send('zdbs.deploy', payload_encoded)?
	return json.decode(DeployResponse, response.data)
}

pub fn (mut client TwinClient) zdb_add_zdb(zdb AddZDB) ?DeployResponse {
	// Add new zdb to zdbs deployment
	payload_encoded := json.encode(zdb)
	response := client.send('zdbs.add_zdb', payload_encoded)?
	return json.decode(DeployResponse, response.data)
}

pub fn (mut client TwinClient) zdb_delete_zdb(zdb_to_delete SingleDelete) ?ContractResponse {
	// Delete single zdb from a zdbs deployment
	payload_encoded := json.encode_pretty(zdb_to_delete)
	response := client.send('zdbs.delete_zdb', payload_encoded)?
	return json.decode(ContractResponse, response.data)
}

pub fn (mut client TwinClient) zdb_get(name string) ?[]Deployment {
	// Get zdbs info using deployment name
	response := client.send('zdbs.get', json.encode({"name": name}))?
	return json.decode([]Deployment, response.data)
}

pub fn (mut client TwinClient) zdb_update(payload ZDBs) ?DeployResponse {
	// Update zdbs with updated payload.
	payload_encoded := json.encode_pretty(payload)
	response := client.send('zdbs.update', payload_encoded)?
	return json.decode(DeployResponse, response.data)
}

pub fn (mut client TwinClient) zdb_list() ?[]string {
	// List all my zdbs deployments
	response := client.send('zdbs.list', '{}')?
	return json.decode([]string, response.data)
}

pub fn (mut client TwinClient) zdb_delete(name string) ?ContractResponse {
	// Delete zdbs deployment
	response := client.send('zdbs.delete', json.encode({"name": name}))?
	return json.decode(ContractResponse, response.data)
}
