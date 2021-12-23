module twinclient

import threefoldtech.info_specs_grid3.vlang.zos
import json

pub fn (mut tw Client) deploy_machines(payload Machines) ?DeployResponse {
	/*
	Deploy generic machine workload
		Input:
			- payload (Machine): generic machine payload
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config.
	*/
	payload_encoded := json.encode_pretty(payload)
	return tw.deploy_machines_with_encoded_payload(payload_encoded)
}

pub fn (mut tw Client) deploy_machines_with_encoded_payload(payload_encoded string) ?DeployResponse {
	/*
	Deploy generic machine workload with encoded payload
		Input:
			- payload (string): generic machine encoded payload.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config
	*/
	mut msg := tw.send('twinserver.machines.deploy', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

pub fn (mut tw Client) get_machines(name string) ?[]zos.Deployment {
	/*
	Get machine info using deployment name
		Input:
			- name (string): Deployment name
		Output:
			- Deployments: List of zos Deplyments
	*/
	mut msg := tw.send('twinserver.machines.get', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode([]zos.Deployment, response.data) or {}
}

pub fn (mut tw Client) update_machine(payload Machine) ?DeployResponse {
	/*
	Update machine with payload.
		Input:
			- payload (Machine): machine instance with modified data.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config
	*/
	payload_encoded := json.encode_pretty(payload)
	return tw.update_machine_with_encoded_payload(payload_encoded)
}

pub fn (mut tw Client) update_machine_with_encoded_payload(payload_encoded string) ?DeployResponse {
	/*
	Get machine info using deployment name.
		Input:
			- payload_encoded (string): encoded payload with modified data.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config
	*/
	mut msg := tw.send('twinserver.machine.update', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

pub fn (mut tw Client) list_machines() ?[]string {
	/*
	List all generic machines
		Output:
			- machines: Array of all current machines name for specifc twin.
	*/
	mut msg := tw.send('twinserver.machine.list', '{}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode([]string, response.data) or {}
}

pub fn (mut tw Client) delete_machine(name string) ?ContractDeployResponse {
	/*
	Delete deployed machine.
		Input:
			- name (string): machine name.
		Output:
			- response: List of contracts {deleted}.
	*/
	mut msg := tw.send('twinserver.machine.delete', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(ContractDeployResponse, response.data) or {}
}
