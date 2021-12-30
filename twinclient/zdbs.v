module twinclient

import threefoldtech.info_specs_grid3.vlang.zos
import json

// Deploy zdbs workload
pub fn (mut tw Client) deploy_zdbs(payload ZDBs) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.zdbs.deploy', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

// Add new zdb to zdbs deployment
pub fn (mut tw Client) add_zdb(zdb AddZDB) ?DeployResponse {
	payload_encoded := json.encode(zdb)
	mut msg := tw.send('twinserver.zdbs.add_zdb', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

// Delete single zdb from a zdbs deployment
pub fn (mut tw Client) delete_zdb(zdb_to_delete SingleDelete) ?ContractResponse {
	payload_encoded := json.encode_pretty(zdb_to_delete)
	mut msg := tw.send('twinserver.zdbs.delete_zdb', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(ContractResponse, response.data) or {}
}

// Get zdbs info using deployment name
pub fn (mut tw Client) get_zdbs(name string) ?[]zos.Deployment {
	mut msg := tw.send('twinserver.zdbs.get', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]zos.Deployment, response.data) or {}
}

// Update zdbs with updated payload.
pub fn (mut tw Client) update_zdbs(payload ZDBs) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.zdbs.update', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

// List all my zdbs deployments
pub fn (mut tw Client) list_zdbs() ?[]string {
	mut msg := tw.send('twinserver.zdbs.list', '{}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]string, response.data) or {}
}

// Delete zdbs deployment
pub fn (mut tw Client) delete_zdbs(name string) ?ContractResponse {
	mut msg := tw.send('twinserver.zdbs.delete', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(ContractResponse, response.data) or {}
}
