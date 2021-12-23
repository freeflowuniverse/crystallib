module twinclient

import threefoldtech.info_specs_grid3.vlang.zos
import json

pub fn (mut tw Client) deploy_zdbs(payload ZDBs) ?ContractDeployResponse {
	/*
	Deploy zdb workload
		Input:
			- payload (ZDBs): zdb payload
		Output:
			- response: List of contracts {created}.
	*/
	payload_encoded := json.encode_pretty(payload)
	return tw.deploy_zdbs_with_encoded_payload(payload_encoded)
}

pub fn (mut tw Client) deploy_zdbs_with_encoded_payload(payload_encoded string) ?ContractDeployResponse {
	/*
	Deploy zdb workload with encoded payload
		Input:
			- payload (string): zdb encoded payload.
		Output:
			- response: List of contracts {created}.
	*/
	mut msg := tw.send('twinserver.zdbs.deploy', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(ContractDeployResponse, response.data) or {}
}

pub fn (mut tw Client) add_zdb(zdb AddZDB) ?ContractDeployResponse {
	/*
	Add new zdb to zdbs deployment
		Input:
			- zdb (AddZDB): ZDB object contains new zdb info and deployment name.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config.
	*/
	payload_encoded := json.encode(zdb)
	mut msg := tw.send('twinserver.zdbs.add_zdb', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(ContractDeployResponse, response.data) or {}
}

pub fn (mut tw Client) delete_zdb(zdb_to_delete SingleDelete) ?ContractDeployResponse {
	/*
	Delete zdb from a zdbs deployment
		Input:
			- zdb_to_delete (SingleDelete): struct contains name and deployment name.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config.
	*/
	payload_encoded := json.encode_pretty(zdb_to_delete)
	mut msg := tw.send('twinserver.zdbs.delete_zdb', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(ContractDeployResponse, response.data) or {}
}

pub fn (mut tw Client) get_zdbs(name string) ?[]zos.Deployment {
	/*
	Get zdb info using deployment name
		Input:
			- name (string): Deployment name
		Output:
			- Deployments: List of all zos Deplyments related to zdbs deployment.
	*/
	mut msg := tw.send('twinserver.zdbs.get', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode([]zos.Deployment, response.data) or {}
}

pub fn (mut tw Client) update_zdbs(payload ZDBs) ?ContractDeployResponse {
	/*
	Update zdb with payload.
		Input:
			- payload (ZDBs): zdb instance with modified data.
		Output:
			- response: List of contracts {updated}.
	*/
	payload_encoded := json.encode_pretty(payload)
	return tw.update_zdbs_with_encoded_payload(payload_encoded)
}

pub fn (mut tw Client) update_zdbs_with_encoded_payload(payload_encoded string) ?ContractDeployResponse {
	/*
	Get zdb info using deployment name.
		Input:
			- payload_encoded (string): encoded payload with modified data.
		Output:
			- response: List of contracts {created}.
	*/
	mut msg := tw.send('twinserver.zdbs.update', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(ContractDeployResponse, response.data) or {}
}

pub fn (mut tw Client) list_zdbs() ?[]string {
	/*
	List all zdbs
		Output:
			- Deployments: Array of all current zdbs name for specifc twin.
	*/
	mut msg := tw.send('twinserver.zdbs.list', '{}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode([]string, response.data) or {}
}

pub fn (mut tw Client) delete_zdbs(name string) ?ContractDeployResponse {
	/*
	Delete deployed zdb.
		Input:
			- name (string): zdb name.
		Output:
			- response: List of contracts {deleted}.
	*/
	mut msg := tw.send('twinserver.zdbs.delete', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(ContractDeployResponse, response.data) or {}
}
