module tfgrid

import json

// Deploy machines workload
pub fn (mut client TFGridClient) machines_deploy(deployment MachinesModel) !MachinesResult {
	payload_encoded := json.encode(deployment)
	response := client.rpc.call(cmd: 'machines.deploy', data: payload_encoded)!
	if response.error != '' {
		return error(response.error)
	}
	return json.decode(MachinesResult, response.result)
}

// Get machines deployment info using deployment name
pub fn (mut client TFGridClient) machines_get(name string) ![]Deployment {
	response := client.rpc.call(
		cmd: 'machines.get'
		data: name
	)!
	if response.error != '' {
		return error(response.error)
	}

	return json.decode([]Deployment, response.result)
}

// Delete a deployed machines using project name
pub fn (mut client TFGridClient) machines_delete(name string) ! {
	response := client.rpc.call(
		cmd: 'machines.delete'
		data: name
	)!

	if response.error != '' {
		return error(response.error)
	}
}

// Update deployed machines deployment with updated payload
pub fn (mut client TFGridClient) machines_update(payload MachinesModel) !MachinesResult {
	payload_encoded := json.encode_pretty(payload)
	response := client.rpc.call(cmd: 'machines.update', data: payload_encoded)!
	if response.error != '' {
		return error(response.error)
	}
	return json.decode(MachinesResult, response.result)
}

// List all my machines deployments
pub fn (mut client TFGridClient) machines_list() ![]string {
	response := client.rpc.call(cmd: 'machines.list', data: '{}')!
	return json.decode([]string, response)
}

// Add new machine to a machines deployment
pub fn (mut client TFGridClient) machines_add_machine(machine AddMachine) !DeployResponse {
	payload_encoded := json.encode_pretty(machine)
	response := client.rpc.call(cmd: 'machines.add_machine', data: payload_encoded)!

	return json.decode(DeployResponse, response)
}

// Delete machine from a machines deployment
pub fn (mut client TFGridClient) machines_delete_machine(machine_to_delete SingleDelete) !ContractResponse {
	payload_encoded := json.encode_pretty(machine_to_delete)
	response := client.rpc.call(cmd: 'machines.delete_machine', data: payload_encoded)!

	return json.decode(ContractResponse, response)
}
