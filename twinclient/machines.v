module twinclient

import threefoldtech.info_specs_grid3.vlang.zos
import json

// Deploy machines workload
pub fn (mut tw Client) deploy_machines(payload Machines) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.machines.deploy', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

// Get machines deployment info using deployment name
pub fn (mut tw Client) get_machines(name string) ?[]zos.Deployment {
	mut msg := tw.send('twinserver.machines.get', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]zos.Deployment, response.data) or {}
}

// Update deployed machines deployment with updated payload
pub fn (mut tw Client) update_machines(payload Machines) ?DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	mut msg := tw.send('twinserver.machines.update', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

// List all my machines deployments
pub fn (mut tw Client) list_machines() ?[]string {
	mut msg := tw.send('twinserver.machines.list', '{}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode([]string, response.data) or {}
}

// Delete a deployed machines using deployment name
pub fn (mut tw Client) delete_machines(name string) ?ContractResponse {
	mut msg := tw.send('twinserver.machines.delete', '{"name": "$name"}') ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(ContractResponse, response.data) or {}
}

// Add new machine to a machines deployment
pub fn (mut tw Client) add_machine(machine AddMachine) ?DeployResponse {
	payload_encoded := json.encode_pretty(machine)
	mut msg := tw.send('twinserver.machines.add_machine', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(DeployResponse, response.data) or {}
}

// Delete machine from a machines deployment
pub fn (mut tw Client) delete_machine(machine_to_delete SingleDelete) ?ContractResponse {
	payload_encoded := json.encode_pretty(machine_to_delete)
	mut msg := tw.send('twinserver.machines.delete_machine', payload_encoded) ?
	response := tw.read(msg)
	if response.err != '' {
		return error(response.err)
	}
	return json.decode(ContractResponse, response.data) or {}
}
