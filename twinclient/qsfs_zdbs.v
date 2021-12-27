module twinclient

import threefoldtech.info_specs_grid3.vlang.zos
import json

pub fn (mut tw Client) deploy_qsfs_zdbs(payload QSFSZDBs) ?ContractDeployResponse {
	/*
	Deploy qsfs_zdbs workload
		Input:
			- payload (QSFSZDBs): qsfs_zdbs payload
		Output:
			- response: List of contracts {created}.
	*/
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.qsfs_zdbs.deploy', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(ContractDeployResponse, response.data) or {}
}

pub fn (mut tw Client) get_qsfs_zdbs(name string) ?[]zos.Deployment {
	/*
	Get qsfs_zdbs info using deployment name
		Input:
			- name (string): Deployment name
		Output:
			- Deployments: List of all zos Deplyments related to qsfs_zdbs deployment.
	*/
	mut msg := tw.send('twinserver.qsfs_zdbs.get', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode([]zos.Deployment, response.data) or {}
}

pub fn (mut tw Client) list_qsfs_zdbs() ?[]string {
	/*
	List all qsfs_zdbs
		Output:
			- Deployments: Array of all current qsfs_zdbs name for specifc twin.
	*/
	mut msg := tw.send('twinserver.qsfs_zdbs.list', '{}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode([]string, response.data) or {}
}

pub fn (mut tw Client) delete_qsfs_zdbs(name string) ?ContractDeployResponse {
	/*
	Delete deployed qsfs_zdbs.
		Input:
			- name (string): qsfs_zdbs name.
		Output:
			- response: List of contracts {deleted}.
	*/
	mut msg := tw.send('twinserver.qsfs_zdbs.delete', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(ContractDeployResponse, response.data) or {}
}
