module twinclient2

import json



fn new_zdbs(mut client TwinClient) ZDBS {
	// Initialize new zdbs.
	return ZDBS{
		client: unsafe {client}
	}
}

pub fn (mut zdb ZDBS) deploy(payload ZDBs) ?DeployResponse {
	// Deploy zdbs workload
	payload_encoded := json.encode_pretty(payload)
	response := zdb.client.send('zdbs.deploy', payload_encoded)?
	return json.decode(DeployResponse, response.data)
}

pub fn (mut db ZDBS) add_zdb(zdb AddZDB) ?DeployResponse {
	// Add new zdb to zdbs deployment
	payload_encoded := json.encode(zdb)
	response := db.client.send('zdbs.add_zdb', payload_encoded)?
	return json.decode(DeployResponse, response.data)
}

pub fn (mut zdb ZDBS) delete_zdb(zdb_to_delete SingleDelete) ?ContractResponse {
	// Delete single zdb from a zdbs deployment
	payload_encoded := json.encode_pretty(zdb_to_delete)
	response := zdb.client.send('zdbs.delete_zdb', payload_encoded)?
	return json.decode(ContractResponse, response.data)
}

pub fn (mut zdb ZDBS) get(name string) ?[]Deployment {
	// Get zdbs info using deployment name
	response := zdb.client.send('zdbs.get', json.encode({"name": name}))?
	return json.decode([]Deployment, response.data)
}

pub fn (mut zdb ZDBS) update(payload ZDBs) ?DeployResponse {
	// Update zdbs with updated payload.
	payload_encoded := json.encode_pretty(payload)
	response := zdb.client.send('zdbs.update', payload_encoded)?
	return json.decode(DeployResponse, response.data)
}

pub fn (mut zdb ZDBS) list() ?[]string {
	// List all my zdbs deployments
	response := zdb.client.send('zdbs.list', '{}')?
	return json.decode([]string, response.data)
}

pub fn (mut zdb ZDBS) delete(name string) ?ContractResponse {
	// Delete zdbs deployment
	response := zdb.client.send('zdbs.delete', json.encode({"name": name}))?
	return json.decode(ContractResponse, response.data)
}
