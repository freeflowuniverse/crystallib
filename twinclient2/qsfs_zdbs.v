module twinclient2

import json



fn new_qsfs_zdbs(mut client TwinClient) QsfsZdbs {
	// Initialize new qsfs_zdbs.
	return QsfsZdbs{
		client: unsafe {client}
	}
}

// Deploy new qsfs_zdbs
pub fn (mut tw TwinClient) deploy(payload QSFSZDBs) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := tw.send('qsfs_zdbs.deploy', payload_encoded)?

	return json.decode(DeployResponse, response.data)
}

// Get deployed qsfs_zdbs by deployment name
pub fn (mut tw TwinClient) get(name string) ?[]Deployment {
	response := tw.send('qsfs_zdbs.get', json.encode({"name": name}))?

	return json.decode([]Deployment, response.data)
}

// List all my qsfs_zdbs
pub fn (mut tw TwinClient) list() ?[]string {
	response := tw.send('qsfs_zdbs.list', '{}')?

	return json.decode([]string, response.data)
}

// Delete deployed qsfs_zdbs using deployment name
pub fn (mut tw TwinClient) delete(name string) ?ContractResponse {
	response := tw.send('qsfs_zdbs.delete', json.encode({"name": name}))?

	return json.decode(ContractResponse, response.data)
}
