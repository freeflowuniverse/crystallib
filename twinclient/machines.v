module twinclient

import threefoldtech.info_specs_grid3.vlang.zos
import json

pub fn (mut tw Client) deploy_machines(payload Machines) ?DeployResponse {
	/*
	Deploy machines workload
		Input:
			- payload (Machine): generic machine payload
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config.
	*/
	payload_encoded := json.encode_pretty(payload)
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

pub fn (mut tw Client) update_machines(payload Machines) ?DeployResponse {
	/*
	Update machine with payload.
		Input:
			- payload (Machine): machine instance with modified data.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config
	*/
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.machines.update', payload_encoded) ?
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
	mut msg := tw.send('twinserver.machines.list', '{}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode([]string, response.data) or {}
}

pub fn (mut tw Client) delete_machines(name string) ?ContractDeployResponse {
	/*
	Delete deployed machine.
		Input:
			- name (string): machine name.
		Output:
			- response: List of contracts {deleted}.
	*/
	mut msg := tw.send('twinserver.machines.delete', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(ContractDeployResponse, response.data) or {}
}

pub fn (mut tw Client) add_machine(machine AddMachine) ?DeployResponse {
	/*
	Add new machine to a Machines deployment
		Input:
			- machine: AddMachine Object contains new machine info.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config.
	*/
	payload_encoded := json.encode_pretty(machine)
	mut msg := tw.send('twinserver.machines.add_machine', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

pub fn (mut tw Client) delete_machine(machine_to_delete SingleDelete) ?ContractDeployResponse {
	/*
	Delete machine from a Machines deployment
		Input:
			- machine_to_delete (SingleDelete): struct contains name and deployment name.
		Output:
			- DeployResponse: list of contracts {created updated, deleted} and wireguard config.
	*/
	payload_encoded := json.encode_pretty(machine_to_delete)
	mut msg := tw.send('twinserver.machines.delete_machine', payload_encoded) ?
	response := tw.read(msg)
	if response.err != ''{
		return error(response.err)
	}
	return json.decode(ContractDeployResponse, response.data) or {}
}
