module twinclient

import json


// Deploy new qsfs_zdbs
pub fn (mut client TwinClient) qsfs_zbd_deploy(payload QSFSZDBs) !DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := client.transport.send('qsfs_zdbs.deploy', payload_encoded)!

	return json.decode(DeployResponse, response.data)
}

// Get deployed qsfs_zdbs by deployment name
pub fn (mut client TwinClient) qsfs_zbd_get(name string) ![]Deployment {
	response := client.transport.send('qsfs_zdbs.get', json.encode({"name": name}))!

	return json.decode([]Deployment, response.data)
}

// List all my qsfs_zdbs
pub fn (mut client TwinClient) qsfs_zbd_list() ![]string {
	response := client.transport.send('qsfs_zdbs.list', '{}')!

	return json.decode([]string, response.data)
}

// Delete deployed qsfs_zdbs using deployment name
pub fn (mut client TwinClient) qsfs_zbd_delete(name string) !ContractResponse {
	response := client.transport.send('qsfs_zdbs.delete', json.encode({"name": name}))!

	return json.decode(ContractResponse, response.data)
}
