module twinclient2

import json

// Deploy new qsfs_zdbs
pub fn (mut tw TwinClient) deploy_qsfs_zdbs(payload QSFSZDBs) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('qsfs_zdbs.deploy', payload_encoded)?

	return json.decode(DeployResponse, response.data) or {}
}

// Get deployed qsfs_zdbs by deployment name
pub fn (mut tw TwinClient) get_qsfs_zdbs(name string) ?[]Deployment {
	response := tw.send('qsfs_zdbs.get', '{"name": "$name"}')?

	return json.decode([]Deployment, response.data) or {}
}

// List all my qsfs_zdbs
pub fn (mut tw TwinClient) list_qsfs_zdbs() ?[]string {
	response := tw.send('qsfs_zdbs.list', '{}')?

	return json.decode([]string, response.data) or {}
}

// Delete deployed qsfs_zdbs using deployment name
pub fn (mut tw TwinClient) delete_qsfs_zdbs(name string) ?ContractResponse {
	response := tw.send('qsfs_zdbs.delete', '{"name": "$name"}')?

	return json.decode(ContractResponse, response.data) or {}
}
