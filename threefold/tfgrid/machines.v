module tfgrid

import json

// Deploy machines workload
pub fn (mut client TFGridClient) machines_deploy(payload MachinesModel) !DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := client.rpc.call(cmd: 'machines.deploy', data: payload_encoded)!
	return json.decode(DeployResponse, response)
}

// Get machines deployment info using deployment name
pub fn (mut client TFGridClient) machines_get(name string) ![]Deployment {
	response := client.rpc.call(
		cmd: 'machines.get'
		data: json.encode_pretty({
			'name': name
		})
	)!
	return json.decode([]Deployment, response)
}

// Update deployed machines deployment with updated payload
pub fn (mut client TFGridClient) machines_update(payload MachinesModel) !DeployResponse {
	payload_encoded := json.encode_pretty(payload)
	response := client.rpc.call(cmd: 'machines.update', data: payload_encoded)!

	return json.decode(DeployResponse, response)
}

// List all my machines deployments
pub fn (mut client TFGridClient) machines_list() ![]string {
	response := client.rpc.call(cmd: 'machines.list', data: '{}')!
	return json.decode([]string, response)
}

// Delete a deployed machines using deployment name
pub fn (mut client TFGridClient) machines_delete(name string) !ContractResponse {
	response := client.rpc.call(
		cmd: 'machines.delete'
		data: json.encode({
			'name': name
		})
	)!

	return json.decode(ContractResponse, response)
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
