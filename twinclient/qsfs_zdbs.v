module twinclient

import json

// Deploy new qsfs_zdbs
pub fn (mut tw Client) deploy_qsfs_zdbs(payload QSFSZDBs) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.qsfs_zdbs.deploy', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

// Get deployed qsfs_zdbs by deployment name
pub fn (mut tw Client) get_qsfs_zdbs(name string) ?[]Deployment {
	mut msg := tw.send('twinserver.qsfs_zdbs.get', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]Deployment, response.data) or {}
}

// List all my qsfs_zdbs
pub fn (mut tw Client) list_qsfs_zdbs() ?[]string {
	mut msg := tw.send('twinserver.qsfs_zdbs.list', '{}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]string, response.data) or {}
}

// Delete deployed qsfs_zdbs using deployment name
pub fn (mut tw Client) delete_qsfs_zdbs(name string) ?ContractResponse {
	mut msg := tw.send('twinserver.qsfs_zdbs.delete', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(ContractResponse, response.data) or {}
}
