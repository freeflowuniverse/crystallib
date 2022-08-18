module twinclient2

import json

// Deploy zdbs workload
pub fn (mut tw TwinClient) deploy_zdbs(payload ZDBs) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('zdbs.deploy', payload_encoded)?

	return json.decode(DeployResponse, response.data) or {}
}

// Add new zdb to zdbs deployment
pub fn (mut tw TwinClient) add_zdb(zdb AddZDB) ?DeployResponse {
	payload_encoded := json.encode(zdb)
	response := tw.send('zdbs.add_zdb', payload_encoded)?

	return json.decode(DeployResponse, response.data) or {}
}

// Delete single zdb from a zdbs deployment
pub fn (mut tw TwinClient) delete_zdb(zdb_to_delete SingleDelete) ?ContractResponse {
	payload_encoded := json.encode_pretty(zdb_to_delete)
	response := tw.send('zdbs.delete_zdb', payload_encoded)?

	return json.decode(ContractResponse, response.data) or {}
}

// Get zdbs info using deployment name
pub fn (mut tw TwinClient) get_zdbs(name string) ?[]Deployment {
	response := tw.send('zdbs.get', '{"name": "$name"}')?

	return json.decode([]Deployment, response.data) or {}
}

// Update zdbs with updated payload.
pub fn (mut tw TwinClient) update_zdbs(payload ZDBs) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('zdbs.update', payload_encoded)?

	return json.decode(DeployResponse, response.data) or {}
}

// List all my zdbs deployments
pub fn (mut tw TwinClient) list_zdbs() ?[]string {
	response := tw.send('zdbs.list', '{}')?

	return json.decode([]string, response.data) or {}
}

// Delete zdbs deployment
pub fn (mut tw TwinClient) delete_zdbs(name string) ?ContractResponse {
	response := tw.send('zdbs.delete', '{"name": "$name"}')?

	return json.decode(ContractResponse, response.data) or {}
}
