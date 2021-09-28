module twinclient

import threefoldtech.info_specs_grid3.vlang.zos
import json

pub struct ZDB {
pub mut:
	deployment_name string
	name            string
	node_id         u32
	mode            string
	disk_size       u32
	disk_type       string
	public          bool
	namespace       string
	password        string
}

pub struct DeployZDBPayload {
pub:
	name        string
	zdbs        []ZDB
	metadata    string
	description string
}

pub fn (mut tw Client) deploy_zdbs(payload DeployZDBPayload) ?ContractDeployResponse {
	/*
	Deploy zdb workload
		Input:
			- payload (DeployZDBPayload): zdb payload
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

pub fn (mut tw Client) add_zdb(deployment_name string, zdb ZDB) ?ContractDeployResponse {
	/*
	Add new zdb to zdbs deployment
		Input:
			- deployment_name (string): Deployment name.
			- zdb (Node): ZDB object contains new zdb info.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config.
	*/
	mut add_payload := zdb
	add_payload.deployment_name = deployment_name
	payload_encoded := json.encode(add_payload)
	mut msg := tw.send('twinserver.zdbs.add_zdb', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(ContractDeployResponse, response.data) or {}
}

pub fn (mut tw Client) delete_zdb(deployment_name string, zdb_name string) ?ContractDeployResponse {
	/*
	Delete zdb from a zdbs deployment
		Input:
			- deployment_name (string): Deployment name.
			- name (string): zdb name to delete.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config.
	*/
	mut delete_payload := map[string]string{}
	delete_payload = {
		'deployment_name': deployment_name
		'name':            zdb_name
	}
	payload_encoded := json.encode_pretty(delete_payload)
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

pub fn (mut tw Client) update_zdbs(payload DeployZDBPayload) ?ContractDeployResponse {
	/*
	Update zdb with payload.
		Input:
			- payload (DeployZDBPayload): zdb instance with modified data.
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
